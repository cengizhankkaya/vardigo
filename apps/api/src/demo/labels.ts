import type { CandidateLabels } from "../modules/candidates/http/candidates-routes.js";
import seedData from "./seed.json" with { type: "json" };

/** Fixed header numbers from the reference design; the real list has 4 people. */
export const candidateLabels: CandidateLabels = {
  totalPerfect: seedData.labels.totalPerfect,
  totalSimilar: seedData.labels.totalSimilar,
  selectedHint: 1,
};
