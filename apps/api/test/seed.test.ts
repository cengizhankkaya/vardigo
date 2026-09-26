import { describe, expect, it } from "vitest";
import { openDatabase } from "../src/platform/database/connection.js";
import { migrate } from "../src/platform/database/migrations.js";
import { resolveExpiresAt, seedDatabase } from "../src/demo/seed.js";
import seedData from "../src/demo/seed.json" with { type: "json" };
import { tempDbPath } from "./support/temp-db.js";

const NOW = Date.UTC(2026, 8, 26, 10, 0);
const HOUR = 3_600_000;

function freshDb(path = tempDbPath()) {
  const db = openDatabase(path);
  migrate(db);
  return db;
}

function count(db: ReturnType<typeof openDatabase>, table: string) {
  return db.prepare(`SELECT COUNT(*) AS n FROM ${table}`).get()?.n;
}

describe("resolveExpiresAt", () => {
  it("resolves the case placeholders relative to now", () => {
    expect(resolveExpiresAt("USE_NOW_PLUS_21H32M", NOW)).toBe(NOW + 21 * HOUR + 32 * 60_000);
    expect(resolveExpiresAt("USE_NOW_PLUS_18H00M", NOW)).toBe(NOW + 18 * HOUR);
  });

  it("accepts ISO dates and rejects unknown values", () => {
    expect(resolveExpiresAt("2026-09-20T11:45:00.000Z", NOW)).toBe(Date.UTC(2026, 8, 20, 11, 45));
    expect(() => resolveExpiresAt("tomorrow", NOW)).toThrow(/çözümlenemedi/);
  });
});

describe("seedDatabase", () => {
  it("loads 2 users, 4 candidates and 3 pending offers", () => {
    const db = freshDb();
    expect(seedDatabase(db, NOW)).toBe(true);
    expect(count(db, "users")).toBe(2);
    expect(count(db, "candidates")).toBe(4);
    expect(count(db, "offers")).toBe(3);

    const komi = db.prepare("SELECT status, expires_at_ms FROM offers WHERE id = 'o_komi'").get();
    expect(komi).toEqual({ status: "pending", expires_at_ms: NOW + 18 * HOUR });
  });

  it("keeps existing data when run again", () => {
    const db = freshDb();
    seedDatabase(db, NOW);
    db.exec("UPDATE offers SET status = 'accepted', responded_at_ms = 1 WHERE id = 'o_garson'");

    expect(seedDatabase(db, NOW + HOUR)).toBe(false);
    const garson = db.prepare("SELECT status, expires_at_ms FROM offers WHERE id = 'o_garson'").get();
    expect(garson).toEqual({ status: "accepted", expires_at_ms: NOW + 21 * HOUR + 32 * 60_000 });
  });

  it("persists across reopening the database file", () => {
    const path = tempDbPath();
    const first = freshDb(path);
    seedDatabase(first, NOW);
    first.exec("UPDATE offers SET status = 'rejected', responded_at_ms = 1 WHERE id = 'o_barista'");
    first.close();

    const reopened = freshDb(path);
    expect(seedDatabase(reopened, NOW)).toBe(false);
    expect(reopened.prepare("SELECT status FROM offers WHERE id = 'o_barista'").get()?.status).toBe("rejected");
  });

  it("writes nothing when the seed is invalid", () => {
    const db = freshDb();
    const broken = structuredClone(seedData);
    broken.offers[2]!.expiresAt = "bad";
    expect(() => seedDatabase(db, NOW, broken)).toThrow();
    expect(count(db, "users")).toBe(0);
    expect(count(db, "app_meta")).toBe(0);
  });

  it("rejects candidates whose perfect flag disagrees with score", () => {
    const db = freshDb();
    const broken = structuredClone(seedData);
    broken.candidates[0]!.score = 50;
    expect(() => seedDatabase(db, NOW, broken)).toThrow(/perfect/);
  });
});
