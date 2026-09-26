import type { Candidate } from "./candidate.js";

/** Port: the candidate pool, in seed order. */
export interface CandidatesRepository {
  findAll(): Candidate[];
}
