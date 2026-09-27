import type { NewOffer, Offer, OfferSort, OfferStatus } from "./offer.js";

/** Port: where offers are kept. Calls run inside the caller's unit of work. */
export interface OffersRepository {
  /** Marks pending offers whose time is up as expired. */
  expireDue(nowMs: number): void;
  candidatesWithPendingOffer(candidateIds: readonly string[]): string[];
  /** Status of the newest offer sent to each candidate; candidates never sent one are absent. */
  latestStatusByCandidate(): Map<string, OfferStatus>;
  insert(offer: NewOffer): void;
  listForRecipient(recipientUserId: string, statuses: readonly OfferStatus[], sort?: OfferSort): Offer[];
  countPending(recipientUserId: string): number;
  findForRecipient(id: string, recipientUserId: string): Offer | undefined;
  /** Records the decision only if the offer is still pending and not past its time. */
  markResponded(id: string, recipientUserId: string, status: "accepted" | "rejected", nowMs: number): boolean;
}
