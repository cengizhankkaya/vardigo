import { seedDatabase } from "../demo/seed.js";
import { type Database, openDatabase } from "../platform/database/connection.js";
import { migrate } from "../platform/database/migrations.js";

export function prepareDatabase(path: string): Database {
  const db = openDatabase(path);
  migrate(db);
  if (seedDatabase(db, Date.now())) {
    console.log(`Seed verisi yüklendi: ${path}`);
  }
  return db;
}
