import { Ajv2020 } from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
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

  describe("responses match their schemas", () => {
    const ajv = new Ajv2020({ allErrors: true });
    addFormats.default(ajv);
    // The document's own top-level keys and `example` are annotations; the schemas under
    // them are still checked strictly.
    for (const key of ["example", ...Object.keys(openApiDocument)]) ajv.addKeyword(key);
    ajv.addSchema(openApiDocument, "openapi");

    const pointer = (...parts: string[]) =>
      parts.map((p) => encodeURIComponent(p.replaceAll("~", "~0").replaceAll("/", "~1"))).join("/");
    const schemaFor = (method: string, path: string, status: number) =>
      ajv.getSchema(`openapi#/${pointer("paths", path, method, "responses", String(status), "content", "application/json", "schema")}`);

    type Call = (api: ReturnType<typeof request>) => request.Test;
    const employer = { Authorization: "Bearer dev-employer" };
    const worker = { Authorization: "Bearer dev-worker" };
    const accept = (api: ReturnType<typeof request>) => api.post("/api/offers/o_garson/accept").set(worker);

    /** One real request per documented response; setup calls run first. */
    const cases: [method: string, path: string, status: number, call: Call, setup?: Call][] = [
      ["get", "/health", 200, (api) => api.get("/api/health")],
      ["post", "/auth/login", 200, (api) => api.post("/api/auth/login").send({ role: "worker" })],
      ["post", "/auth/login", 400, (api) => api.post("/api/auth/login").send({ role: "admin" })],
      ["get", "/candidates", 200, (api) => api.get("/api/candidates").set(employer)],
      ["get", "/candidates", 400, (api) => api.get("/api/candidates?tab=all").set(employer)],
      ["get", "/candidates", 401, (api) => api.get("/api/candidates").set(worker)],
      ["post", "/offers", 201, (api) => api.post("/api/offers").set(employer).send({ workerIds: ["w_merve", "w_derya"] })],
      ["post", "/offers", 400, (api) => api.post("/api/offers").set(employer).send({ workerIds: [] })],
      ["post", "/offers", 401, (api) => api.post("/api/offers").send({ workerIds: ["w_merve"] })],
      ["post", "/offers", 404, (api) => api.post("/api/offers").set(employer).send({ workerIds: ["w_x"] })],
      [
        "post",
        "/offers",
        409,
        (api) => api.post("/api/offers").set(employer).send({ workerIds: ["w_merve"] }),
        (api) => api.post("/api/offers").set(employer).send({ workerIds: ["w_merve"] }),
      ],
      ["get", "/offers", 200, (api) => api.get("/api/offers?status=pending").set(worker)],
      ["get", "/offers", 400, (api) => api.get("/api/offers?status=all").set(worker)],
      ["get", "/offers", 401, (api) => api.get("/api/offers").set(employer)],
      ["get", "/offers/{id}", 200, (api) => api.get("/api/offers/o_garson").set(worker)],
      ["get", "/offers/{id}", 401, (api) => api.get("/api/offers/o_garson")],
      ["get", "/offers/{id}", 404, (api) => api.get("/api/offers/o_none").set(worker)],
      ...(["accept", "reject"] as const).flatMap((action) => {
        const path = `/offers/{id}/${action}`;
        const answer = (id: string) => (api: ReturnType<typeof request>) =>
          api.post(`/api/offers/${id}/${action}`).set(worker);
        return [
          ["post", path, 200, answer("o_garson")],
          ["post", path, 400, (api) => api.post(`/api/offers/o_garson/${action}`).set(worker).send({ x: 1 })],
          ["post", path, 401, (api) => api.post(`/api/offers/o_garson/${action}`)],
          ["post", path, 404, answer("o_none")],
          ["post", path, 409, answer("o_garson"), accept],
        ] satisfies (typeof cases)[number][];
      }),
    ];

    it("has a case for every documented response", () => {
      const documented = Object.entries(openApiDocument.paths).flatMap(([path, methods]) =>
        Object.entries(methods).flatMap(([method, op]) =>
          Object.keys(op.responses).map((status) => `${method} ${path} ${status}`),
        ),
      );
      expect(cases.map(([method, path, status]) => `${method} ${path} ${status}`).sort()).toEqual(documented.sort());
    });

    it.each(cases)("%s %s → %i", async (method, path, status, call, setup) => {
      const api = request(app);
      if (setup) await setup(api);
      const res = await call(api);
      expect(res.status).toBe(status);
      const validate = schemaFor(method, path, status);
      expect(validate, "schema").toBeDefined();
      validate!(res.body);
      expect(validate!.errors ?? [], JSON.stringify(res.body)).toEqual([]);
    });
  });
});
