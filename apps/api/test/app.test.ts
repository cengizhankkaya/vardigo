import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

describe("app", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  it("returns the success envelope from health", async () => {
    const res = await request(app).get("/api/health");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ ok: true, data: { status: "up" } });
    expect(res.headers["x-powered-by"]).toBeUndefined();
  });

  it("returns the error envelope for unknown routes", async () => {
    const res = await request(app).get("/api/unknown");
    expect(res.status).toBe(404);
    expect(res.body).toEqual({
      ok: false,
      error: { code: "NOT_FOUND", message: "Endpoint bulunamadı" },
    });
  });

  it("returns 400 for malformed JSON", async () => {
    const res = await request(app)
      .post("/api/health")
      .set("Content-Type", "application/json")
      .send("{bad");
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("INVALID_JSON");
  });

  it("returns 413 for a body over 100 KB", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .set("Content-Type", "application/json")
      .send(JSON.stringify({ role: "x".repeat(200_000) }));
    expect(res.status).toBe(413);
    expect(res.body.error.code).toBe("PAYLOAD_TOO_LARGE");
  });

  it("returns 415 for a body that is not JSON", async () => {
    const res = await request(app).post("/api/auth/login").set("Content-Type", "text/plain").send("role=worker");
    expect(res.status).toBe(415);
    expect(res.body.error.code).toBe("UNSUPPORTED_MEDIA_TYPE");
  });

  it("returns 415 for a non UTF-8 JSON charset", async () => {
    const res = await request(app)
      .post("/api/auth/login")
      .set("Content-Type", "application/json; charset=latin1")
      .send('{"role":"worker"}');
    expect(res.status).toBe(415);
  });

  it("returns 400 for a badly encoded URL", async () => {
    const res = await request(app).post("/api/offers/%E0%A4%A/accept").set("Authorization", "Bearer dev-worker");
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe("BAD_REQUEST");
  });
});
