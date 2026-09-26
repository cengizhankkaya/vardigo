import { type Database, transaction } from "./connection.js";

const migrations: { version: number; sql: string }[] = [
  {
    version: 1,
    sql: `
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        role TEXT NOT NULL CHECK (role IN ('employer', 'worker')),
        name TEXT NOT NULL,
        token TEXT NOT NULL UNIQUE
      );

      CREATE TABLE candidates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        rating TEXT NOT NULL,
        attend TEXT NOT NULL,
        km TEXT NOT NULL,
        km_value REAL NOT NULL CHECK (km_value >= 0),
        photo TEXT NOT NULL,
        online INTEGER NOT NULL CHECK (online IN (0, 1)),
        score INTEGER NOT NULL CHECK (score >= 0),
        seed_order INTEGER NOT NULL
      );

      CREATE TABLE offers (
        id TEXT PRIMARY KEY,
        recipient_user_id TEXT NOT NULL REFERENCES users(id),
        candidate_id TEXT REFERENCES candidates(id),
        title TEXT NOT NULL,
        place TEXT NOT NULL,
        pay TEXT NOT NULL,
        pay_value INTEGER NOT NULL CHECK (pay_value >= 0),
        logo TEXT NOT NULL,
        district TEXT NOT NULL,
        when_label TEXT NOT NULL,
        status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
        expires_at_ms INTEGER NOT NULL,
        responded_at_ms INTEGER,
        created_at_ms INTEGER NOT NULL,
        CHECK ((status IN ('accepted', 'rejected')) = (responded_at_ms IS NOT NULL))
      );

      CREATE INDEX offers_recipient_status ON offers (recipient_user_id, status, created_at_ms);
      CREATE INDEX offers_status_expires ON offers (status, expires_at_ms);
      CREATE UNIQUE INDEX offers_one_pending_per_candidate
        ON offers (candidate_id)
        WHERE status = 'pending' AND candidate_id IS NOT NULL;

      CREATE TABLE app_meta (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    `,
  },
];

export function migrate(db: Database): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version INTEGER PRIMARY KEY,
      applied_at_ms INTEGER NOT NULL
    )
  `);
  const applied = new Set(
    db
      .prepare("SELECT version FROM schema_migrations")
      .all()
      .map((row) => Number(row.version)),
  );
  for (const migration of migrations) {
    if (applied.has(migration.version)) continue;
    transaction(db, () => {
      db.exec(migration.sql);
      db.prepare("INSERT INTO schema_migrations (version, applied_at_ms) VALUES (?, ?)").run(
        migration.version,
        Date.now(),
      );
    });
  }
}
