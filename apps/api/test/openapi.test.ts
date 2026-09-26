import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { openApiDocument } from "../src/swagger/openapi.js";
import { createTestApp } from "./support/test-app.js";

describe("API docs", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  it("serves Swagger UI", async () => {
    const res = await request(app).get("/api/docs/");
    expect(res.status).toBe(200);
    expect(res.text).toContain("swagger-ui");
  });

  it("serves the OpenAPI document as JSON", async () => {
    const res = await request(app).get("/api/openapi.json");
    expect(res.status).toBe(200);
    expect(res.body.openapi).toBe("3.1.0");
  });

  const operations = Object.entries(openApiDocument.paths).flatMap(([path, methods]) =>
    Object.keys(methods).map((method) => [method.toUpperCase(), path] as const),
  );

  it.each(operations)("documents a route that exists: %s %s", async (method, path) => {
    const url = `/api${path.replace("{id}", "o_garson")}`;
    const res = await request(app)[method.toLowerCase() as "get" | "post"](url).send({});
    expect(res.body?.error?.code).not.toBe("NOT_FOUND");
  });
});
