export const PERFECT_SCORE = 80;

export const CANDIDATE_TABS = ["perfect", "similar"] as const;
export const CANDIDATE_SORTS = ["recommended", "near", "rating"] as const;

export type CandidateTab = (typeof CANDIDATE_TABS)[number];
export type CandidateSort = (typeof CANDIDATE_SORTS)[number];

export interface Candidate {
  id: string;
  name: string;
  rating: string;
  attend: string;
  km: string;
  kmValue: number;
  photo: string;
  online: boolean;
  score: number;
}

export function isPerfect(candidate: Pick<Candidate, "score">): boolean {
  return candidate.score >= PERFECT_SCORE;
}
