import { request as httpRequest } from "node:http";
import type { AddressInfo } from "node:net";
import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { createTestApp } from "./support/test-app.js";

/** Sends a body with Transfer-Encoding: chunked (no Content-Length), which supertest cannot do. */
async function postChunked(app: ReturnType<typeof createTestApp>["app"], path: string, body: string) {
  const server = app.listen(0, "127.0.0.1");
  await new Promise((resolve) => server.once("listening", resolve));
  try {
    const { port } = server.address() as AddressInfo;
    return await new Promise<{ status: number; body: { error?: { code: string } } }>((resolve, reject) => {
      const req = httpRequest(
        {
          host: "127.0.0.1",
          port,
          path,
          method: "POST",
          headers: { "Content-Type": "text/plain", Authorization: "Bearer dev-worker" },
        },
        (res) => {
          let text = "";
          res.setEncoding("utf8");
          res.on("data", (chunk: string) => (text += chunk));
          res.on("end", () => resolve({ status: res.statusCode ?? 0, body: JSON.parse(text) }));
        },
      );
      req.on("error", reject);
      req.write(body);
      req.end();
    });
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

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

  it("returns 415 for a chunked body that is not JSON and leaves the offer untouched", async () => {
    const { app: chunkedApp, db } = createTestApp();
    const res = await postChunked(chunkedApp, "/api/offers/o_garson/accept", "anything");
    expect(res.status).toBe(415);
    expect(res.body.error?.code).toBe("UNSUPPORTED_MEDIA_TYPE");
    expect(db.prepare("SELECT status FROM offers WHERE id = 'o_garson'").get()?.status).toBe("pending");
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
