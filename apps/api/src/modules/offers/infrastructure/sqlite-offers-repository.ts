import type { Database } from "../../../platform/database/connection.js";
import type { NewOffer, Offer, OfferSort, OfferStatus } from "../domain/offer.js";
import type { OffersRepository } from "../domain/offers-repository.js";

const OFFER_COLUMNS = "id, title, place, pay, logo, district, when_label, status, expires_at_ms";

// Ties fall back to insert order so the list never jumps between requests.
const ORDER_BY: Record<OfferSort, string> = {
  recommended: "created_at_ms DESC, rowid ASC",
  expiring: "expires_at_ms ASC, rowid ASC",
  pay: "pay_value DESC, rowid ASC",
};

function toOffer(row: Record<string, unknown>): Offer {
  return {
    id: String(row.id),
    title: String(row.title),
    place: String(row.place),
    pay: String(row.pay),
    logo: String(row.logo),
    district: String(row.district),
    when: String(row.when_label),
    status: row.status as OfferStatus,
    expiresAtMs: Number(row.expires_at_ms),
  };
}

export class SqliteOffersRepository implements OffersRepository {
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

  listForRecipient(recipientUserId: string, statuses: readonly OfferStatus[], sort: OfferSort = "recommended"): Offer[] {
    const placeholders = statuses.map(() => "?").join(", ");
    return this.db
      .prepare(
        `SELECT ${OFFER_COLUMNS} FROM offers
         WHERE recipient_user_id = ? AND status IN (${placeholders})
         ORDER BY ${ORDER_BY[sort]}`,
      )
      .all(recipientUserId, ...statuses)
      .map(toOffer);
  }

  countPending(recipientUserId: string): number {
    const row = this.db
      .prepare("SELECT COUNT(*) AS n FROM offers WHERE recipient_user_id = ? AND status = 'pending'")
      .get(recipientUserId);
    return Number(row?.n ?? 0);
  }

  findForRecipient(id: string, recipientUserId: string): Offer | undefined {
    const row = this.db
      .prepare(`SELECT ${OFFER_COLUMNS} FROM offers WHERE id = ? AND recipient_user_id = ?`)
      .get(id, recipientUserId);
    return row ? toOffer(row) : undefined;
  }

  /** Records the decision only if the offer is still pending and not past its time. */
  markResponded(id: string, recipientUserId: string, status: "accepted" | "rejected", nowMs: number): boolean {
    const result = this.db
      .prepare(
        `UPDATE offers SET status = ?, responded_at_ms = ?
         WHERE id = ? AND recipient_user_id = ? AND status = 'pending' AND expires_at_ms > ?`,
      )
      .run(status, nowMs, id, recipientUserId, nowMs);
    return result.changes === 1;
  }
}
