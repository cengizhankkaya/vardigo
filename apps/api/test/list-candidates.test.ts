import { describe, expect, it } from "vitest";
import { countCandidates, listCandidates } from "../src/modules/candidates/application/list-candidates.js";
import type { Candidate } from "../src/modules/candidates/domain/candidate.js";

function candidate(id: string, score: number, rating: string, kmValue: number): Candidate {
  return { id, name: id, rating, attend: "", km: `${kmValue} km`, kmValue, photo: "", online: true, score };
}

// Same values as the first four case seed candidates, in seed order.
const seed = [
  candidate("merve", 92, "4.9", 4.9),
  candidate("derya", 71, "4.2", 1.7),
  candidate("ayse", 64, "3.8", 1.2),
  candidate("ferhat", 88, "4.9", 4.9),
];

const ids = (list: Candidate[]) => list.map((c) => c.id);

describe("listCandidates", () => {
  it("returns everyone by score when no tab is given", () => {
    expect(ids(listCandidates(seed))).toEqual(["merve", "ferhat", "derya", "ayse"]);
  });

  it("splits tabs at score 80", () => {
    expect(ids(listCandidates(seed, { tab: "perfect" }))).toEqual(["merve", "ferhat"]);
    expect(ids(listCandidates(seed, { tab: "similar" }))).toEqual(["derya", "ayse"]);
  });

  it("counts both tabs from the pool", () => {
    expect(countCandidates(seed)).toEqual({ totalPerfect: 2, totalSimilar: 2 });
    expect(countCandidates([candidate("edge", 80, "1", 1)])).toEqual({ totalPerfect: 1, totalSimilar: 0 });
    expect(countCandidates([])).toEqual({ totalPerfect: 0, totalSimilar: 0 });
  });

  it("treats score 80 as perfect", () => {
    expect(ids(listCandidates([candidate("edge", 80, "1", 1)], { tab: "perfect" }))).toEqual(["edge"]);
  });

  it("sorts near by distance ascending", () => {
    expect(ids(listCandidates(seed, { sort: "near" }))).toEqual(["ayse", "derya", "merve", "ferhat"]);
  });

  it("sorts rating descending and keeps seed order on ties", () => {
    expect(ids(listCandidates(seed, { sort: "rating" }))).toEqual(["merve", "ferhat", "derya", "ayse"]);
  });

  it("does not mutate the input", () => {
    const input = [...seed];
    listCandidates(input, { sort: "near" });
    expect(input).toEqual(seed);
  });
});
