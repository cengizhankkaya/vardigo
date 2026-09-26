import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp, TEST_NOW } from "./support/test-app.js";

const HOUR = 3_600_000;

describe("GET /api/offers", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  let now: number;
  beforeEach(() => {
    now = TEST_NOW;
    ({ app } = createTestApp({ now: () => now }));
  });

  const list = (query = "") => request(app).get(`/api/offers${query}`).set("Authorization", "Bearer dev-worker");

  it("returns the seed offers in the case format", async () => {
    const res = await list("?status=pending");
    expect(res.status).toBe(200);
    expect(res.body.data.pendingCount).toBe(3);
    expect(res.body.data.pendingCountLabel).toBe(12);
    expect(res.body.data.offers[0]).toEqual({
      id: "o_garson",
      title: "Garson",
      place: "Zarif Cheff Restaurant",
      pay: "45.000",
      logo: "/assets/logos/zarif.svg",
      district: "Kadıköy",
      when: "16 Ağu · 12:00 - 16:00",
      status: "pending",
      remain: "21 saat 32 dakika",
      expiresAt: new Date(TEST_NOW + (21 * 60 + 32) * 60_000).toISOString(),
    });
  });

  it("defaults to the pending tab", async () => {
    const res = await list();
    expect(res.body.data.offers.map((o: { id: string }) => o.id)).toEqual(["o_garson", "o_barista", "o_komi"]);
  });

  it("shows offers sent by the employer in the pending tab", async () => {
    await request(app)
      .post("/api/offers")
      .set("Authorization", "Bearer dev-employer")
      .send({ workerIds: ["w_merve", "w_derya"] });
    const res = await list("?status=pending");
    expect(res.body.data.pendingCount).toBe(5);
    expect(res.body.data.offers).toHaveLength(5);
  });

  it("counts down and moves offers to the expired tab", async () => {
    now = TEST_NOW + 17 * HOUR + 30 * 60_000;
    const pending = await list();
    expect(pending.body.data.offers.find((o: { id: string }) => o.id === "o_komi").remain).toBe("0 saat 30 dakika");

    now = TEST_NOW + 18 * HOUR;
    const expired = await list("?status=expired");
    expect(expired.body.data.offers).toHaveLength(1);
    expect(expired.body.data.offers[0]).toMatchObject({ id: "o_komi", status: "expired", remain: "0 saat 0 dakika" });
    expect((await list()).body.data.pendingCount).toBe(2);
  });

  it.each([
    ["recommended", ["o_garson", "o_barista", "o_komi"]],
    ["expiring", ["o_komi", "o_garson", "o_barista"]],
    ["pay", ["o_garson", "o_barista", "o_komi"]],
  ])("sorts by %s", async (sort, expected) => {
    const res = await list(`?sort=${sort}`);
    expect(res.body.data.offers.map((o: { id: string }) => o.id)).toEqual(expected);
  });

  it("puts new offers first by default and keeps ties in insert order", async () => {
    now = TEST_NOW + 1000;
    await request(app).post("/api/offers").set("Authorization", "Bearer dev-employer").send({ workerIds: ["w_merve"] });
    const recommended = await list();
    const pay = await list("?sort=pay");
    expect(recommended.body.data.offers[0].id).toMatch(/^o_(?!garson)/);
    expect(pay.body.data.offers.slice(0, 2).map((o: { place: string }) => o.place)).toEqual([
      "Zarif Cheff Restaurant",
      "Zarif Cheff Restaurant",
    ]);
    expect(pay.body.data.offers[0].id).toBe("o_garson");
  });

  it("returns an empty answered tab on a fresh seed", async () => {
    const res = await list("?status=answered");
    expect(res.body.data.offers).toEqual([]);
  });

  it.each(["?status=accepted", "?status=all", "?status=pending&status=expired", "?sort=price"])("rejects %s with 400", async (q) => {
    const res = await list(q);
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("allows only the job seeker", async () => {
    const res = await request(app).get("/api/offers").set("Authorization", "Bearer dev-employer");
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe("ROLE_NOT_ALLOWED");
  });
});

describe("GET /api/offers/:id", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  const get = (id: string) => request(app).get(`/api/offers/${id}`).set("Authorization", "Bearer dev-worker");

  it("returns the offer with city and note", async () => {
    const res = await get("o_barista");
    expect(res.status).toBe(200);
    expect(res.body.data).toMatchObject({
      id: "o_barista",
      place: "Horizon Cafe",
      city: "İstanbul",
      note: "Şube: Sinanpaşa Mah.",
    });
  });

  it("returns 404 for an unknown id", async () => {
    const res = await get("o_missing");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("OFFER_NOT_FOUND");
  });
});
