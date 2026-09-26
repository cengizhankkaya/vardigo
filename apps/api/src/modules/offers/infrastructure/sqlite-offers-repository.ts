import type { Database } from "../../../platform/database/connection.js";
import type { NewOffer } from "../domain/offer.js";

export class SqliteOffersRepository {
  constructor(private readonly db: Database) {}

  /** Marks pending offers whose time is up as expired. */
  expireDue(nowMs: number): void {
    this.db
      .prepare("UPDATE offers SET status = 'expired' WHERE status = 'pending' AND expires_at_ms <= ?")
      .run(nowMs);
  }

  candidatesWithPendingOffer(candidateIds: readonly string[]): string[] {
    if (candidateIds.length === 0) return [];
    const placeholders = candidateIds.map(() => "?").join(", ");
    return this.db
      .prepare(`SELECT candidate_id FROM offers WHERE status = 'pending' AND candidate_id IN (${placeholders})`)
      .all(...candidateIds)
      .map((row) => String(row.candidate_id));
  }

  insert(offer: NewOffer): void {
    const { job } = offer;
    this.db
      .prepare(
        `INSERT INTO offers (id, recipient_user_id, candidate_id, title, place, pay, pay_value, logo,
           district, when_label, status, expires_at_ms, created_at_ms)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?)`,
      )
      .run(
        offer.id, offer.recipientUserId, offer.candidateId, job.title, job.place, job.pay, job.payValue,
        job.logo, job.district, job.when, offer.createdAtMs + job.validForMs, offer.createdAtMs,
      );
  }
}
