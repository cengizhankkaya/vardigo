import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

const EMPLOYER = "Bearer dev-employer";

describe("GET /api/candidates", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  let db: ReturnType<typeof createTestApp>["db"];
  beforeEach(() => {
    ({ app, db } = createTestApp());
  });

  const get = (query = "") => request(app).get(`/api/candidates${query}`).set("Authorization", EMPLOYER);

  it("returns the 12 seed candidates with counts of both tabs", async () => {
    const res = await get();
    expect(res.status).toBe(200);
    expect(res.body.ok).toBe(true);
    expect(res.body.data).toMatchObject({ totalPerfect: 6, totalSimilar: 6, selectedHint: 1 });
    expect(res.body.data.candidates).toHaveLength(12);
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
    expect(pay).toMatchObject({ w_merve: true, w_ferhat: false, w_derya: false, w_ayse: true });
    expect(res.body.data.candidates.every((c: { expectedPay: string | null }) => c.expectedPay !== null)).toBe(true);
  });

  it("filters by tab and keeps the counts of both tabs", async () => {
    const perfect = await get("?tab=perfect");
    const similar = await get("?tab=similar");
    expect(perfect.body.data.candidates.map((c: { id: string }) => c.id)).toEqual([
      "w_merve", "w_elif", "w_ferhat", "w_burak", "w_zeynep", "w_emre",
    ]);
    expect(similar.body.data.candidates.map((c: { id: string }) => c.id)).toEqual([
      "w_selin", "w_can", "w_derya", "w_irem", "w_ayse", "w_mert",
    ]);
    for (const res of [perfect, similar]) {
      expect(res.body.data).toMatchObject({ totalPerfect: 6, totalSimilar: 6 });
    }
  });

  it("counts from the candidate table, not a fixed label", async () => {
    db.prepare(
      `INSERT INTO candidates (id, name, rating, attend, km, km_value, photo, online, score, seed_order)
       VALUES ('w_new', 'Yeni A.', '4.0', '%90 katılım', '1 km', 1, 'photos/merve.png', 1, 80, 99)`,
    ).run();
    const res = await get("?tab=similar");
    expect(res.body.data).toMatchObject({ totalPerfect: 7, totalSimilar: 6 });
    expect(res.body.data.candidates.find((c: { id: string }) => c.id === "w_new")).toBeUndefined();
  });

  it("sorts by distance", async () => {
    const res = await get("?sort=near");
    expect(res.body.data.candidates.map((c: { km: string }) => c.km)).toEqual([
      "0.8 km", "1.2 km", "1.7 km", "2.3 km", "2.9 km", "3.1 km",
      "3.8 km", "4.9 km", "4.9 km", "5.6 km", "6.4 km", "7.2 km",
    ]);
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
