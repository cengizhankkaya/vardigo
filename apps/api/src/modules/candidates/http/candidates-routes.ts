import { type RequestHandler, Router } from "express";
import { optionalQuery } from "../../../platform/http/query.js";
import { sendOk } from "../../../platform/http/response.js";
import type { OfferStatus } from "../../offers/domain/offer.js";
import { getCandidateList, type GetCandidateListDeps } from "../application/get-candidate-list.js";
import { type Candidate, type CandidatePay, CANDIDATE_SORTS, CANDIDATE_TABS, isPerfect } from "../domain/candidate.js";

/** "25.000", same style as the offer pay field. */
function formatPay(value: number): string {
  return value.toLocaleString("tr-TR", { maximumFractionDigits: 0 });
}

function toDto(candidate: Candidate, offerStatus: OfferStatus | null, pay: CandidatePay | undefined) {
  return {
    id: candidate.id,
    name: candidate.name,
    rating: candidate.rating,
    attend: candidate.attend,
    km: candidate.km,
    photo: `/assets/${candidate.photo}`,
    online: candidate.online,
    perfect: isPerfect(candidate),
    score: candidate.score,
    expectedPay: pay ? formatPay(pay.expectedPay) : null,
    payCompatible: pay?.payCompatible ?? null,
    offerStatus,
  };
}

export function candidatesRoutes(
  list: GetCandidateListDeps,
  selectedHint: number,
  pay: Record<string, CandidatePay>,
  guard: RequestHandler,
): Router {
  const router = Router();

  router.get("/", guard, (req, res) => {
    const tab = optionalQuery(req.query.tab, "tab", CANDIDATE_TABS);
    const sort = optionalQuery(req.query.sort, "sort", CANDIDATE_SORTS);
    const listing = getCandidateList(list, { tab, sort });
    sendOk(res, {
      totalPerfect: listing.totalPerfect,
      totalSimilar: listing.totalSimilar,
      selectedHint,
      candidates: listing.candidates.map(({ candidate, offerStatus }) =>
        toDto(candidate, offerStatus, pay[candidate.id]),
      ),
    });
  });

  return router;
}
