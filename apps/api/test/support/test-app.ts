import { createApp } from "../../src/app.js";
import { seedDatabase } from "../../src/demo/seed.js";
import { openDatabase } from "../../src/platform/database/connection.js";
import { migrate } from "../../src/platform/database/migrations.js";
import { tempDbPath } from "./temp-db.js";

export const TEST_NOW = Date.UTC(2026, 8, 26, 10, 0);

/** App backed by a fresh seeded database file. */
export function createTestApp() {
  const db = openDatabase(tempDbPath());
  migrate(db);
  seedDatabase(db, TEST_NOW);
  return { app: createApp({ db }), db };
}
