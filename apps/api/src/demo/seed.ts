import { isPerfect, PERFECT_SCORE } from "../modules/candidates/domain/candidate.js";
import { type Database, transaction } from "../platform/database/connection.js";
import seedData from "./seed.json" with { type: "json" };

export type SeedData = typeof seedData;

const SEED_MARKER = "seeded_at_ms";

export function resolveExpiresAt(value: string, now: number): number {
  const match = /^USE_NOW_PLUS_(\d+)H(\d+)M$/.exec(value);
  if (match) {
    return now + (Number(match[1]) * 60 + Number(match[2])) * 60_000;
  }
  const date = Date.parse(value);
  if (Number.isNaN(date)) {
    throw new Error(`Seed expiresAt çözümlenemedi: ${value}`);
  }
  return date;
}

function validate(data: SeedData): void {
  for (const candidate of data.candidates) {
    if (candidate.perfect !== isPerfect(candidate)) {
      throw new Error(`Seed adayı ${candidate.id}: perfect alanı score >= ${PERFECT_SCORE} ile uyuşmuyor`);
    }
  }
  const userIds = new Set(data.users.map((user) => user.id));
  for (const offer of data.offers) {
    if (!userIds.has(offer.workerId)) {
      throw new Error(`Seed teklifi ${offer.id}: bilinmeyen workerId ${offer.workerId}`);
    }
  }
}

function isSeeded(db: Database): boolean {
  return db.prepare("SELECT 1 FROM app_meta WHERE key = ?").get(SEED_MARKER) !== undefined;
}

function hasDomainRows(db: Database): boolean {
  return db.prepare("SELECT 1 FROM users UNION ALL SELECT 1 FROM offers LIMIT 1").get() !== undefined;
}

/** Loads the case seed once. Later runs keep existing data. Returns true if data was written. */
export function seedDatabase(db: Database, now: number, data: SeedData = seedData): boolean {
  if (isSeeded(db)) return false;
  if (hasDomainRows(db)) {
    throw new Error("Veritabanında seed işareti yok ama veri var; `npm run db:reset` ile sıfırlayın");
  }
  validate(data);

  transaction(db, () => {
    const insertUser = db.prepare("INSERT INTO users (id, role, name, token) VALUES (?, ?, ?, ?)");
    for (const user of data.users) {
      insertUser.run(user.id, user.role, user.name, user.token);
    }

    const insertCandidate = db.prepare(`
      INSERT INTO candidates (id, name, rating, attend, km, km_value, photo, online, score, seed_order)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    data.candidates.forEach((c, index) => {
      insertCandidate.run(c.id, c.name, c.rating, c.attend, c.km, c.kmValue, c.photo, c.online ? 1 : 0, c.score, index);
    });

    const insertOffer = db.prepare(`
      INSERT INTO offers (id, recipient_user_id, candidate_id, title, place, pay, pay_value, logo,
        district, when_label, status, expires_at_ms, created_at_ms)
      VALUES (?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);
    for (const o of data.offers) {
      insertOffer.run(
        o.id, o.workerId, o.title, o.place, o.pay, o.payValue, o.logo, o.district, o.when, o.status,
        resolveExpiresAt(o.expiresAt, now), now,
      );
    }

    db.prepare("INSERT INTO app_meta (key, value) VALUES (?, ?)").run(SEED_MARKER, String(now));
  });
  return true;
}
