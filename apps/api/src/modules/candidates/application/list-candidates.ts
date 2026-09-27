import { type Candidate, type CandidateSort, type CandidateTab, isPerfect } from "../domain/candidate.js";

const comparators: Record<CandidateSort, (a: Candidate, b: Candidate) => number> = {
  recommended: (a, b) => b.score - a.score,
  near: (a, b) => a.kmValue - b.kmValue,
  rating: (a, b) => Number(b.rating) - Number(a.rating),
};

/** Header counts of both tabs, from the whole pool whatever tab is shown. */
export function countCandidates(candidates: readonly Candidate[]): { totalPerfect: number; totalSimilar: number } {
  const totalPerfect = candidates.filter(isPerfect).length;
  return { totalPerfect, totalSimilar: candidates.length - totalPerfect };
}

/** Filters by tab and sorts; ties keep the incoming (seed) order. */
export function listCandidates(
  candidates: readonly Candidate[],
  options: { tab?: CandidateTab; sort?: CandidateSort } = {},
): Candidate[] {
  const { tab, sort = "recommended" } = options;
  const filtered = tab ? candidates.filter((c) => isPerfect(c) === (tab === "perfect")) : [...candidates];
  return filtered.sort(comparators[sort]);
}
