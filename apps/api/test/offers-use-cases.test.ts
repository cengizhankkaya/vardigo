import { beforeEach, describe, expect, it } from "vitest";
import { getCandidateList } from "../src/modules/candidates/application/get-candidate-list.js";
import type { Candidate } from "../src/modules/candidates/domain/candidate.js";
import type { CandidatesRepository } from "../src/modules/candidates/domain/candidates-repository.js";
import { createOffers } from "../src/modules/offers/application/create-offers.js";
import { listOffers } from "../src/modules/offers/application/list-offers.js";
import { respondToOffer } from "../src/modules/offers/application/respond-to-offer.js";
import type { NewOffer, Offer, OfferJob, OfferSort, OfferStatus } from "../src/modules/offers/domain/offer.js";
import type { OffersRepository } from "../src/modules/offers/domain/offers-repository.js";
import type { UnitOfWork } from "../src/platform/unit-of-work.js";

/**
 * The offer use cases against in-memory ports: the business rules hold
 * without SQLite. The SQLite adapters have their own tests.
 */

const HOUR = 3_600_000;
const NOW = 1_000 * HOUR;
const USER = "u_worker";

const job: OfferJob = {
  title: "Garson",
  place: "Zarif",
  pay: "45.000",
  payValue: 45_000,
  logo: "logos/zarif.svg",
  district: "Kadıköy",
  when: "16 Ağu",
  validForMs: 24 * HOUR,
};

interface Row extends Offer {
  recipientUserId: string;
  candidateId: string;
  createdAtMs: number;
}

class InMemoryOffers implements OffersRepository {
  rows: Row[] = [];

  expireDue(nowMs: number): void {
    for (const row of this.rows) if (row.status === "pending" && row.expiresAtMs <= nowMs) row.status = "expired";
  }

  candidatesWithPendingOffer(candidateIds: readonly string[]): string[] {
    return this.rows.filter((r) => r.status === "pending" && candidateIds.includes(r.candidateId)).map((r) => r.candidateId);
  }

  latestStatusByCandidate(): Map<string, OfferStatus> {
    const newestLast = [...this.rows].sort((a, b) => a.createdAtMs - b.createdAtMs);
    return new Map(newestLast.map((r) => [r.candidateId, r.status]));
  }

  insert({ id, recipientUserId, candidateId, job, createdAtMs }: NewOffer): void {
    const { title, place, pay, logo, district, when } = job;
    this.rows.push({
      id,
      title,
      place,
      pay,
      logo,
      district,
      when,
      recipientUserId,
      candidateId,
      createdAtMs,
      status: "pending",
      expiresAtMs: createdAtMs + job.validForMs,
    });
  }

  listForRecipient(recipientUserId: string, statuses: readonly OfferStatus[], _sort?: OfferSort): Offer[] {
    return this.rows
      .filter((r) => r.recipientUserId === recipientUserId && statuses.includes(r.status))
      .sort((a, b) => b.createdAtMs - a.createdAtMs);
  }

  countPending(recipientUserId: string): number {
    return this.listForRecipient(recipientUserId, ["pending"]).length;
  }

  findForRecipient(id: string, recipientUserId: string): Offer | undefined {
    const row = this.rows.find((r) => r.id === id && r.recipientUserId === recipientUserId);
    return row && { ...row };
  }

  markResponded(id: string, recipientUserId: string, status: "accepted" | "rejected", nowMs: number): boolean {
    const row = this.rows.find(
      (r) => r.id === id && r.recipientUserId === recipientUserId && r.status === "pending" && r.expiresAtMs > nowMs,
    );
    if (row) row.status = status;
    return row !== undefined;
  }
}

const candidate = (id: string): Candidate => ({
  id,
  name: id,
  rating: "4.9",
  attend: "%100 katılım",
  km: "1 km",
  kmValue: 1,
  photo: `photos/${id}.png`,
  online: true,
  score: 90,
});

describe("offer use cases without a database", () => {
  let offers: InMemoryOffers;
  let units: number;
  let now: number;

  /** Keeps the rows as they were when the work throws, like a rollback. */
  const unitOfWork: UnitOfWork = (work) => {
    units++;
    const before = structuredClone(offers.rows);
    try {
      return work();
    } catch (error) {
      offers.rows = before;
      throw error;
    }
  };
  const candidates: CandidatesRepository = { findAll: () => [candidate("w_merve"), candidate("w_derya")] };
  const createDeps = () => {
    let seq = 0;
    return { unitOfWork, offers, candidates, job, recipientUserId: USER, now: () => now, newId: () => `o_${++seq}` };
  };

  beforeEach(() => {
    offers = new InMemoryOffers();
    units = 0;
    now = NOW;
  });

  it("creates the whole batch in one unit of work", () => {
    expect(createOffers(createDeps(), ["w_merve", "w_derya"]).kind).toBe("created");
    expect(units).toBe(1);
    expect(offers.rows.map((r) => [r.candidateId, r.status, r.expiresAtMs])).toEqual([
      ["w_merve", "pending", NOW + 24 * HOUR],
      ["w_derya", "pending", NOW + 24 * HOUR],
    ]);
  });

  it("sends nothing when one candidate is unknown", () => {
    expect(createOffers(createDeps(), ["w_merve", "w_x"])).toEqual({ kind: "candidate_not_found", workerId: "w_x" });
    expect(offers.rows).toEqual([]);
  });

  it("an expired pending offer does not block a new one", () => {
    createOffers(createDeps(), ["w_merve"]);
    expect(createOffers(createDeps(), ["w_merve"])).toEqual({ kind: "pending_exists", workerIds: ["w_merve"] });

    now = NOW + 24 * HOUR;
    expect(createOffers(createDeps(), ["w_merve"]).kind).toBe("created");
  });

  it("an answer after the deadline reports expired and keeps it expired", () => {
    createOffers(createDeps(), ["w_merve"]);
    now = NOW + 24 * HOUR;
    expect(respondToOffer({ unitOfWork, offers, now: () => now }, USER, "o_1", "accepted")).toEqual({ kind: "expired" });
    expect(offers.rows[0]?.status).toBe("expired");
  });

  it("a decision is final", () => {
    createOffers(createDeps(), ["w_merve"]);
    const deps = { unitOfWork, offers, now: () => now };
    expect(respondToOffer(deps, USER, "o_1", "rejected").kind).toBe("responded");
    expect(respondToOffer(deps, USER, "o_1", "accepted")).toEqual({ kind: "already_answered" });
    expect(respondToOffer(deps, "u_other", "o_1", "accepted")).toEqual({ kind: "not_found" });
  });

  it("a lost update throws and rolls the unit of work back", () => {
    createOffers(createDeps(), ["w_merve"]);
    offers.markResponded = () => false;
    now = NOW + HOUR;
    offers.rows.push({ ...offers.rows[0]!, id: "o_old", expiresAtMs: NOW });

    expect(() => respondToOffer({ unitOfWork, offers, now: () => now }, USER, "o_1", "accepted")).toThrow();
    // The expiry done inside the failed unit is undone too.
    expect(offers.rows.find((r) => r.id === "o_old")?.status).toBe("pending");
  });

  it("the count and the list agree after offers expire", () => {
    createOffers(createDeps(), ["w_merve"]);
    now = NOW + 24 * HOUR;
    expect(listOffers({ unitOfWork, offers, now: () => now }, USER, "pending")).toMatchObject({
      pendingCount: 0,
      offers: [],
    });
    expect(listOffers({ unitOfWork, offers, now: () => now }, USER, "expired").offers).toHaveLength(1);
  });

  it("the employer sees what became of each request", () => {
    const list = () =>
      getCandidateList({ unitOfWork, candidates, offers, now: () => now }).candidates.map((c) => [
        c.candidate.id,
        c.offerStatus,
      ]);
    expect(list()).toEqual([["w_merve", null], ["w_derya", null]]);

    createOffers(createDeps(), ["w_merve", "w_derya"]);
    respondToOffer({ unitOfWork, offers, now: () => now }, USER, "o_1", "accepted");
    expect(list()).toEqual([["w_merve", "accepted"], ["w_derya", "pending"]]);

    // The pending one runs out; listing closes it rather than showing it as pending.
    now = NOW + 24 * HOUR;
    expect(list()).toEqual([["w_merve", "accepted"], ["w_derya", "expired"]]);
    expect(offers.rows.find((r) => r.id === "o_2")?.status).toBe("expired");

    // A new request after the answer is what the employer sees next.
    createOffers(createDeps(), ["w_merve"]);
    expect(list()).toEqual([["w_merve", "pending"], ["w_derya", "expired"]]);
  });
});
