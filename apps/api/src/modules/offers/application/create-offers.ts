import { randomUUID } from "node:crypto";
import type { UnitOfWork } from "../../../platform/unit-of-work.js";
import type { CandidatesRepository } from "../../candidates/domain/candidates-repository.js";
import type { OfferJob } from "../domain/offer.js";
import type { OffersRepository } from "../domain/offers-repository.js";

export interface CreateOffersDeps {
  unitOfWork: UnitOfWork;
  offers: OffersRepository;
  candidates: CandidatesRepository;
  job: OfferJob;
  recipientUserId: string;
  now: () => number;
  newId?: () => string;
}

export type CreateOffersResult =
  | { kind: "created"; created: { id: string; workerId: string; status: "pending" }[] }
  | { kind: "candidate_not_found"; workerId: string }
  | { kind: "pending_exists"; workerIds: string[] };

/**
 * Sends the demo job to every selected candidate, or to none of them.
 * Expired pending offers are closed first so they do not block a new one;
 * that cleanup is kept even when the request ends in a conflict.
 */
export function createOffers(deps: CreateOffersDeps, workerIds: readonly string[]): CreateOffersResult {
  const newId = deps.newId ?? (() => `o_${randomUUID()}`);

  return deps.unitOfWork((): CreateOffersResult => {
    const now = deps.now();
    const known = new Set(deps.candidates.findAll().map((c) => c.id));
    const unknown = workerIds.find((id) => !known.has(id));
    if (unknown) return { kind: "candidate_not_found", workerId: unknown };

    deps.offers.expireDue(now);
    const blocked = deps.offers.candidatesWithPendingOffer(workerIds);
    if (blocked.length > 0) return { kind: "pending_exists", workerIds: blocked };

    const created = workerIds.map((workerId) => {
      const id = newId();
      deps.offers.insert({
        id,
        recipientUserId: deps.recipientUserId,
        candidateId: workerId,
        job: deps.job,
        createdAtMs: now,
      });
      return { id, workerId, status: "pending" as const };
    });
    return { kind: "created", created };
  });
}
