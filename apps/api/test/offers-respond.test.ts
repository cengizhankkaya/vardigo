import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp, TEST_NOW } from "./support/test-app.js";

const HOUR = 3_600_000;

describe("POST /api/offers/:id/accept and /reject", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  let now: number;
  beforeEach(() => {
    now = TEST_NOW;
    ({ app } = createTestApp({ now: () => now }));
  });

  const respond = (id: string, action: "accept" | "reject", token = "dev-worker") =>
    request(app).post(`/api/offers/${id}/${action}`).set("Authorization", `Bearer ${token}`);

  it("accepts and returns the updated offer", async () => {
    const res = await respond("o_garson", "accept");
    expect(res.status).toBe(200);
    expect(res.body.data).toMatchObject({ id: "o_garson", status: "accepted", remain: "21 saat 32 dakika" });
  });

  it("rejects", async () => {
    const res = await respond("o_barista", "reject");
    expect(res.status).toBe(200);
    expect(res.body.data.status).toBe("rejected");
  });

  it("accepts an empty JSON object as body", async () => {
    const res = await respond("o_garson", "accept").send({});
    expect(res.status).toBe(200);
  });

  it("rejects a body with fields", async () => {
    const res = await respond("o_garson", "accept").send({ status: "rejected" });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("returns 409 OFFER_STATE when already answered", async () => {
    await respond("o_garson", "accept");
    const res = await respond("o_garson", "reject");
    expect(res.status).toBe(409);
    expect(res.body.error).toEqual({ code: "OFFER_STATE", message: "Bu teklif daha önce yanıtlandı" });
  });

  it("returns 409 OFFER_EXPIRED after expiresAt", async () => {
    now = TEST_NOW + 18 * HOUR;
    const res = await respond("o_komi", "accept");
    expect(res.status).toBe(409);
    expect(res.body.error).toEqual({ code: "OFFER_EXPIRED", message: "Teklifin süresi doldu" });
  });

  it("returns 404 for an unknown offer", async () => {
    const res = await respond("o_missing", "accept");
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("OFFER_NOT_FOUND");
  });

  it("returns 401 for the employer", async () => {
    const res = await respond("o_garson", "accept", "dev-employer");
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe("ROLE_NOT_ALLOWED");
  });
});
