import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

describe("CORS", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  it.each(["http://localhost:5173", "http://127.0.0.1:8080", "http://localhost"])("allows %s", async (origin) => {
    const res = await request(app).get("/api/health").set("Origin", origin);
    expect(res.headers["access-control-allow-origin"]).toBe(origin);
  });

  it("answers the preflight for an authorized POST", async () => {
    const res = await request(app)
      .options("/api/offers")
      .set("Origin", "http://localhost:5173")
      .set("Access-Control-Request-Method", "POST")
      .set("Access-Control-Request-Headers", "authorization, content-type");
    expect(res.status).toBe(204);
    expect(res.headers["access-control-allow-headers"]).toContain("Authorization");
    expect(res.headers["access-control-allow-methods"]).toContain("POST");
  });

  it.each(["https://evil.example", "http://localhost.evil.example", "http://192.168.1.5:3000"])(
    "gives no CORS headers to %s",
    async (origin) => {
      const res = await request(app).get("/api/health").set("Origin", origin);
      expect(res.headers["access-control-allow-origin"]).toBeUndefined();
    },
  );
});
