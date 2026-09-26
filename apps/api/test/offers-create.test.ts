import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

describe("POST /api/offers", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  let db: ReturnType<typeof createTestApp>["db"];
  beforeEach(() => {
    ({ app, db } = createTestApp());
  });

  const send = (body: unknown, token = "dev-employer") =>
    request(app).post("/api/offers").set("Authorization", `Bearer ${token}`).send(body as object);
  const newOffers = () => db.prepare("SELECT COUNT(*) AS n FROM offers WHERE candidate_id IS NOT NULL").get()?.n;

  it("creates offers for Merve and Derya", async () => {
    const res = await send({ workerIds: ["w_merve", "w_derya"] });
    expect(res.status).toBe(201);
    expect(res.body.ok).toBe(true);
    expect(res.body.data.created).toEqual([
      { id: expect.stringMatching(/^o_/), workerId: "w_merve", status: "pending" },
      { id: expect.stringMatching(/^o_/), workerId: "w_derya", status: "pending" },
    ]);
    expect(newOffers()).toBe(2);
  });

  it.each([
    [{ workerIds: [] }, "EMPTY_SELECTION"],
    [{ workerIds: ["w_merve", "w_merve"] }, "DUPLICATE_WORKER_IDS"],
    [{}, "VALIDATION_ERROR"],
    [{ workerIds: "w_merve" }, "VALIDATION_ERROR"],
    [{ workerIds: [1] }, "VALIDATION_ERROR"],
    [{ workerIds: [""] }, "VALIDATION_ERROR"],
    [{ workerIds: Array.from({ length: 101 }, (_, i) => `w_${i}`) }, "VALIDATION_ERROR"],
  ])("rejects %j with 400 %s", async (body, code) => {
    const res = await send(body);
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe(code);
    expect(newOffers()).toBe(0);
  });

  it("returns 404 for an unknown candidate and creates nothing", async () => {
    const res = await send({ workerIds: ["w_merve", "w_unknown"] });
    expect(res.status).toBe(404);
    expect(res.body.error.code).toBe("CANDIDATE_NOT_FOUND");
    expect(newOffers()).toBe(0);
  });

  it("returns 409 when a candidate already has a pending offer", async () => {
    await send({ workerIds: ["w_merve"] });
    const res = await send({ workerIds: ["w_derya", "w_merve"] });
    expect(res.status).toBe(409);
    expect(res.body.error.code).toBe("OFFER_PENDING_EXISTS");
    expect(newOffers()).toBe(1);
  });

  it("allows only the employer", async () => {
    const res = await send({ workerIds: ["w_merve"] }, "dev-worker");
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe("ROLE_NOT_ALLOWED");
  });
});
