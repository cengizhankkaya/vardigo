import seedData from "./seed.json" with { type: "json" };

/** How many candidates the list opens with selected (Merve in the reference design). */
export const candidateSelectedHint = 1;

/** Header count from the reference design; `pendingCount` in the API is the real number. */
export const pendingCountLabel: number = seedData.labels.pendingCountLabel;
