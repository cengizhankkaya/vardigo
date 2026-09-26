import { describe, expect, it } from "vitest";
import { openDatabase } from "../src/platform/database/connection.js";
import { migrate } from "../src/platform/database/migrations.js";
import { tempDbPath } from "./support/temp-db.js";

function insertBase(db: ReturnType<typeof openDatabase>) {
  db.exec(`
    INSERT INTO users VALUES ('u_worker', 'worker', 'Ayşe', 'dev-worker');
    INSERT INTO candidates VALUES ('w_merve', 'Merve Y.', '4.9', '%100 katılım', '4.9 km', 4.9, 'photos/merve.png', 1, 92, 0);
  `);
}

function insertPendingOffer(db: ReturnType<typeof openDatabase>, id: string) {
  db.prepare(`
    INSERT INTO offers (id, recipient_user_id, candidate_id, title, place, pay, pay_value, logo,
      district, when_label, status, expires_at_ms, created_at_ms)
    VALUES (?, 'u_worker', 'w_merve', 'Garson', 'Zarif', '45.000', 45000, 'logos/zarif.svg',
      'Kadıköy', '16 Ağu', 'pending', 2000, 1000)
  `).run(id);
}

describe("migrate", () => {
  it("creates the schema once and can run again", () => {
    const db = openDatabase(tempDbPath());
    migrate(db);
    migrate(db);
    const tables = db
      .prepare("SELECT name FROM sqlite_master WHERE type = 'table' ORDER BY name")
      .all()
      .map((row) => row.name);
    expect(tables).toEqual(
      expect.arrayContaining(["app_meta", "candidates", "offers", "schema_migrations", "users"]),
    );
    expect(db.prepare("SELECT COUNT(*) AS n FROM schema_migrations").get()?.n).toBe(1);
  });

  it("enforces foreign keys", () => {
    const db = openDatabase(tempDbPath());
    migrate(db);
    expect(() => insertPendingOffer(db, "o_1")).toThrow(/FOREIGN KEY/);
  });

  it("allows only one pending offer per candidate", () => {
    const db = openDatabase(tempDbPath());
    migrate(db);
    insertBase(db);
    insertPendingOffer(db, "o_1");
    expect(() => insertPendingOffer(db, "o_2")).toThrow(/UNIQUE/);

    db.exec("UPDATE offers SET status = 'expired' WHERE id = 'o_1'");
    expect(() => insertPendingOffer(db, "o_2")).not.toThrow();
  });
});
