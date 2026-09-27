import type { UnitOfWork } from "../../../platform/unit-of-work.js";
import type { OfferStatus } from "../../offers/domain/offer.js";
import type { OffersRepository } from "../../offers/domain/offers-repository.js";
import type { Candidate, CandidateSort, CandidateTab } from "../domain/candidate.js";
import type { CandidatesRepository } from "../domain/candidates-repository.js";
import { countCandidates, listCandidates } from "./list-candidates.js";

export interface GetCandidateListDeps {
  unitOfWork: UnitOfWork;
  candidates: CandidatesRepository;
  offers: OffersRepository;
  now: () => number;
}

export interface CandidateListing {
  totalPerfect: number;
  totalSimilar: number;
  /** Each candidate with the status of the newest offer sent to them; null when none was sent. */
  candidates: { candidate: Candidate; offerStatus: OfferStatus | null }[];
}

/**
 * The employer's view: the tab's candidates and what became of the requests
 * sent to them. Offers past their time are closed first, so a finished
 * countdown reads as expired rather than pending.
 */
export function getCandidateList(
  deps: GetCandidateListDeps,
  options: { tab?: CandidateTab; sort?: CandidateSort } = {},
): CandidateListing {
  return deps.unitOfWork(() => {
    deps.offers.expireDue(deps.now());
    const pool = deps.candidates.findAll();
    const latest = deps.offers.latestStatusByCandidate();
    return {
      ...countCandidates(pool),
      candidates: listCandidates(pool, options).map((candidate) => ({
        candidate,
        offerStatus: latest.get(candidate.id) ?? null,
      })),
    };
  });
}
