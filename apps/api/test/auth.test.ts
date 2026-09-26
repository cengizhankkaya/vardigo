import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

describe("POST /api/auth/login", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  it("returns the employer demo token", async () => {
    const res = await request(app).post("/api/auth/login").send({ role: "employer" });
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ ok: true, data: { token: "dev-employer", role: "employer" } });
  });

  it("returns the worker demo token", async () => {
    const res = await request(app).post("/api/auth/login").send({ role: "worker" });
    expect(res.body.data).toEqual({ token: "dev-worker", role: "worker" });
  });

  it.each([{ role: "admin" }, {}, { role: 1 }])("rejects invalid body %j with 400", async (body) => {
    const res = await request(app).post("/api/auth/login").send(body);
    expect(res.status).toBe(400);
    expect(res.body.ok).toBe(false);
    expect(res.body.error.code).toBe("VALIDATION_ERROR");
  });

  it("rejects a request without a body with 400", async () => {
    const res = await request(app).post("/api/auth/login");
    expect(res.status).toBe(400);
  });
});
