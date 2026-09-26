import { type Database, transaction } from "../../../platform/database/connection.js";
import type { Offer } from "../domain/offer.js";
import type { SqliteOffersRepository } from "../infrastructure/sqlite-offers-repository.js";

export interface RespondToOfferDeps {
  db: Database;
  offers: SqliteOffersRepository;
  now: () => number;
}

export type Decision = "accepted" | "rejected";

export type RespondResult =
  | { kind: "responded"; offer: Offer; now: number }
  | { kind: "not_found" }
  | { kind: "expired" }
  | { kind: "already_answered" };

/**
 * Accepts or rejects a pending offer. An offer past its time is marked expired
 * and that change is committed, even though the caller gets an error.
 */
export function respondToOffer(
  deps: RespondToOfferDeps,
  recipientUserId: string,
  offerId: string,
  decision: Decision,
): RespondResult {
  return transaction(deps.db, (): RespondResult => {
    const now = deps.now();
    deps.offers.expireDue(now);
    const offer = deps.offers.findForRecipient(offerId, recipientUserId);
    if (!offer) return { kind: "not_found" };
    if (offer.status === "expired") return { kind: "expired" };
    if (offer.status !== "pending") return { kind: "already_answered" };

    if (!deps.offers.markResponded(offerId, recipientUserId, decision, now)) {
      throw new Error(`Teklif ${offerId} pending görünüyordu ama güncellenemedi`);
    }
    return { kind: "responded", offer: { ...offer, status: decision }, now };
  });
}
