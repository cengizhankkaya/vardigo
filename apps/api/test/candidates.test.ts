import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

const EMPLOYER = "Bearer dev-employer";

describe("GET /api/candidates", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  const get = (query = "") => request(app).get(`/api/candidates${query}`).set("Authorization", EMPLOYER);

  it("returns the 4 seed candidates with header labels", async () => {
    const res = await get();
    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
    expect(res.body.data).toMatchObject({ totalPerfect: 26, totalSimilar: 16, selectedHint: 1 });
    expect(res.body.data.candidates).toHaveLength(4);
    expect(res.body.data.candidates[0]).toEqual({
      id: "w_merve",
      name: "Merve Y.",
      rating: "4.9",
      attend: "%100 katılım",
      km: "4.9 km",
      photo: "/assets/photos/merve.png",
      online: true,
      perfect: true,
      score: 92,
      expectedPay: "25.000",
      payCompatible: true,
    });
  });

  it("returns the pay line from the reference design", async () => {
    const res = await get();
    const pay = Object.fromEntries(
      res.body.data.candidates.map((c: { id: string; payCompatible: boolean }) => [c.id, c.payCompatible]),
    );
    expect(pay).toEqual({ w_merve: true, w_ferhat: false, w_derya: false, w_ayse: true });
  });

  it("filters by tab", async () => {
    const perfect = await get("?tab=perfect");
    const similar = await get("?tab=similar");
    expect(perfect.body.data.candidates.map((c: { id: string }) => c.id)).toEqual(["w_merve", "w_ferhat"]);
    expect(similar.body.data.candidates.map((c: { id: string }) => c.id)).toEqual(["w_derya", "w_ayse"]);
  });

  it("sorts by distance", async () => {
    const res = await get("?sort=near");
    expect(res.body.data.candidates.map((c: { km: string }) => c.km)).toEqual(["1.2 km", "1.7 km", "4.9 km", "4.9 km"]);
  });

  it.each(["?tab=all", "?sort=price", "?tab=perfect&tab=similar"])("rejects %s with 400", async (query) => {
    const res = await get(query);
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("requires the employer token", async () => {
    const anonymous = await request(app).get("/api/candidates");
    const worker = await request(app).get("/api/candidates").set("Authorization", "Bearer dev-worker");
    expect(anonymous.status).toBe(401);
    expect(worker.status).toBe(401);
    expect(worker.body.error.code).toBe("ROLE_NOT_ALLOWED");
  });
});
