import express from "express";
import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { currentUser, requireRole } from "../src/modules/auth/http/require-role.js";
import { SqliteUsersRepository } from "../src/modules/auth/infrastructure/sqlite-users-repository.js";
import { errorHandler } from "../src/platform/http/error-handler.js";
import { createTestApp } from "./support/test-app.js";

describe("requireRole", () => {
  let app: express.Express;
  beforeEach(() => {
    const users = new SqliteUsersRepository(createTestApp().db);
    app = express();
    app.get("/employer-only", requireRole(users, "employer"), (_req, res) => {
      res.json({ userId: currentUser(res).id });
    });
    app.use(errorHandler);
  });

  it("lets the matching role through", async () => {
    const res = await request(app).get("/employer-only").set("Authorization", "Bearer dev-employer");
    expect(res.status).toBe(200);
    expect(res.body).toEqual({ userId: "u_employer" });
  });

  it("returns 401 AUTH_REQUIRED without a header", async () => {
    const res = await request(app).get("/employer-only");
    expect(res.status).toBe(401);
    expect(res.body.error).toEqual({ code: "AUTH_REQUIRED", message: "Giriş yapmanız gerekiyor" });
  });

  it.each(["Bearer nope", "Basic dev-employer", "Bearer"])("returns 401 INVALID_TOKEN for %j", async (header) => {
    const res = await request(app).get("/employer-only").set("Authorization", header);
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe("INVALID_TOKEN");
  });

  it("accepts the scheme in any case", async () => {
    const res = await request(app).get("/employer-only").set("Authorization", "bearer dev-employer");
    expect(res.status).toBe(200);
  });

  it("returns 401 ROLE_NOT_ALLOWED for the other role", async () => {
    const res = await request(app).get("/employer-only").set("Authorization", "Bearer dev-worker");
    expect(res.status).toBe(401);
    expect(res.body).toEqual({
      ok: false,
      error: { code: "ROLE_NOT_ALLOWED", message: "Bu işlem için yetkiniz yok" },
    });
  });
});
