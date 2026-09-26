import { type Database, transaction } from "../../../platform/database/connection.js";
import { type Offer, type OfferSort, type OfferStatusFilter, statusesFor } from "../domain/offer.js";
import type { SqliteOffersRepository } from "../infrastructure/sqlite-offers-repository.js";

export interface ListOffersDeps {
  db: Database;
  offers: SqliteOffersRepository;
  now: () => number;
}

export interface OfferListing {
  now: number;
  pendingCount: number;
  offers: Offer[];
}

/** Closes expired offers first so the tab contents and the count agree. */
export function listOffers(
  deps: ListOffersDeps,
  recipientUserId: string,
  filter: OfferStatusFilter,
  sort: OfferSort = "recommended",
): OfferListing {
  return transaction(deps.db, () => {
    const now = deps.now();
    deps.offers.expireDue(now);
    return {
      now,
      pendingCount: deps.offers.countPending(recipientUserId),
      offers: deps.offers.listForRecipient(recipientUserId, statusesFor(filter), sort),
    };
  });
}

export function getOffer(
  deps: ListOffersDeps,
  recipientUserId: string,
  offerId: string,
): { now: number; offer: Offer | undefined } {
  return transaction(deps.db, () => {
    const now = deps.now();
    deps.offers.expireDue(now);
    return { now, offer: deps.offers.findForRecipient(offerId, recipientUserId) };
  });
}
