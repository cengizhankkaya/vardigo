import { existsSync } from "node:fs";
import { join } from "node:path";
import request from "supertest";
import { beforeEach, describe, expect, it } from "vitest";
import { ASSETS_DIR } from "../src/app.js";
import seedData from "../src/demo/seed.json" with { type: "json" };
import { createTestApp } from "./support/test-app.js";

describe("/assets", () => {
  let app: ReturnType<typeof createTestApp>["app"];
  beforeEach(() => {
    ({ app } = createTestApp());
  });

  const seedFiles = [...seedData.candidates.map((c) => c.photo), ...seedData.offers.map((o) => o.logo)];

  it.each(seedFiles)("has %s on disk", (file) => {
    expect(existsSync(join(ASSETS_DIR, file))).toBe(true);
  });

  it("serves the photo URL returned by /candidates", async () => {
    const list = await request(app).get("/api/candidates").set("Authorization", "Bearer dev-employer");
    const res = await request(app).get(list.body.data.candidates[0].photo);
    expect(res.status).toBe(200);
    expect(res.headers["content-type"]).toBe("image/png");
  });

  it("serves the logo URL returned by /offers", async () => {
    const list = await request(app).get("/api/offers").set("Authorization", "Bearer dev-worker");
    const res = await request(app).get(list.body.data.offers[0].logo);
    expect(res.status).toBe(200);
    expect(res.headers["content-type"]).toMatch(/^image\/svg\+xml/);
  });

  it.each(["/assets/photos/nobody.png", "/assets/", "/assets/../package.json", "/assets/%2e%2e/package.json"])(
    "returns 404 for %s",
    async (url) => {
      const res = await request(app).get(url);
      expect(res.status).toBe(404);
    },
  );
});
