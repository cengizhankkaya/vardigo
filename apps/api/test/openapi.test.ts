import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { openApiDocument } from "../src/docs/openapi.js";
import { createTestApp } from "./support/test-app.js";

describe("OpenAPI document", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
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
