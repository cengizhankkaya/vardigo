import { type RequestHandler, Router } from "express";
import { optionalQuery } from "../../../platform/http/query.js";
import { sendOk } from "../../../platform/http/response.js";
import { listCandidates } from "../application/list-candidates.js";
import { type Candidate, type CandidatePay, CANDIDATE_SORTS, CANDIDATE_TABS, isPerfect } from "../domain/candidate.js";
import type { CandidatesRepository } from "../domain/candidates-repository.js";

export interface CandidateLabels {
  totalPerfect: number;
  totalSimilar: number;
  selectedHint: number;
}

/** "25.000", same style as the offer pay field. */
function formatPay(value: number): string {
  return value.toLocaleString("tr-TR", { maximumFractionDigits: 0 });
}

function toDto(candidate: Candidate, pay: CandidatePay | undefined) {
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
  };
}

export function candidatesRoutes(
  candidates: CandidatesRepository,
  labels: CandidateLabels,
  pay: Record<string, CandidatePay>,
  guard: RequestHandler,
): Router {
  const router = Router();

  router.get("/", guard, (req, res) => {
    const tab = optionalQuery(req.query.tab, "tab", CANDIDATE_TABS);
    const sort = optionalQuery(req.query.sort, "sort", CANDIDATE_SORTS);
    sendOk(res, {
      ...labels,
      candidates: listCandidates(candidates.findAll(), { tab, sort }).map((c) => toDto(c, pay[c.id])),
    });
  });

  return router;
}
