import { type RequestHandler, Router } from "express";
import { optionalQuery } from "../../../platform/http/query.js";
import { sendOk } from "../../../platform/http/response.js";
import { listCandidates } from "../application/list-candidates.js";
import { type Candidate, CANDIDATE_SORTS, CANDIDATE_TABS, isPerfect } from "../domain/candidate.js";
import type { SqliteCandidatesRepository } from "../infrastructure/sqlite-candidates-repository.js";

export interface CandidateLabels {
  totalPerfect: number;
  totalSimilar: number;
  selectedHint: number;
}

function toDto(candidate: Candidate) {
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
  };
}

export function candidatesRoutes(
  candidates: SqliteCandidatesRepository,
  labels: CandidateLabels,
  guard: RequestHandler,
): Router {
  const router = Router();

  router.get("/", guard, (req, res) => {
    const tab = optionalQuery(req.query.tab, "tab", CANDIDATE_TABS);
    const sort = optionalQuery(req.query.sort, "sort", CANDIDATE_SORTS);
    sendOk(res, {
      ...labels,
      candidates: listCandidates(candidates.findAll(), { tab, sort }).map(toDto),
    });
  });

  return router;
}
