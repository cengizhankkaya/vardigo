import { beforeEach, describe, expect, it } from "vitest";
import type { OfferJob } from "../src/modules/offers/domain/offer.js";
import { SqliteOffersRepository } from "../src/modules/offers/infrastructure/sqlite-offers-repository.js";
import { createTestApp, TEST_NOW } from "./support/test-app.js";

const job: OfferJob = {
  title: "Garson",
  place: "Zarif Cheff Restaurant",
  pay: "45.000",
  payValue: 45000,
  logo: "logos/zarif.svg",
  district: "Kadıköy",
  when: "16 Ağu · 12:00 - 16:00",
  validForMs: 1000,
};

describe("SqliteOffersRepository", () => {
  let db: ReturnType<typeof createTestApp>["db"];
  let offers: SqliteOffersRepository;
  beforeEach(() => {
    ({ db } = createTestApp());
    offers = new SqliteOffersRepository(db);
    offers.insert({ id: "o_1", recipientUserId: "u_worker", candidateId: "w_merve", job, createdAtMs: TEST_NOW });
  });

  const statusOf = (id: string) => db.prepare("SELECT status FROM offers WHERE id = ?").get(id)?.status;

  it("stores a pending offer that expires after validForMs", () => {
    const row = db.prepare("SELECT status, expires_at_ms, candidate_id FROM offers WHERE id = 'o_1'").get();
    expect(row).toEqual({ status: "pending", expires_at_ms: TEST_NOW + 1000, candidate_id: "w_merve" });
  });

  it("finds candidates that already have a pending offer", () => {
    expect(offers.candidatesWithPendingOffer(["w_merve", "w_derya"])).toEqual(["w_merve"]);
    expect(offers.candidatesWithPendingOffer([])).toEqual([]);
  });

  it("reports the newest offer's status per candidate", () => {
    expect(offers.latestStatusByCandidate()).toEqual(new Map([["w_merve", "pending"]]));

    offers.markResponded("o_1", "u_worker", "rejected", TEST_NOW);
    offers.insert({ id: "o_2", recipientUserId: "u_worker", candidateId: "w_merve", job, createdAtMs: TEST_NOW + 1 });
    offers.insert({ id: "o_3", recipientUserId: "u_worker", candidateId: "w_derya", job, createdAtMs: TEST_NOW });
    offers.markResponded("o_3", "u_worker", "accepted", TEST_NOW);
    // The seed's own offers have no candidate and never show up.
    expect(offers.latestStatusByCandidate()).toEqual(
      new Map([
        ["w_derya", "accepted"],
        ["w_merve", "pending"],
      ]),
    );
  });

  it("expires offers exactly at expiresAt, not before", () => {
    offers.expireDue(TEST_NOW + 999);
    expect(statusOf("o_1")).toBe("pending");
    offers.expireDue(TEST_NOW + 1000);
    expect(statusOf("o_1")).toBe("expired");
  });

  it("leaves answered offers alone when expiring", () => {
    db.exec("UPDATE offers SET status = 'accepted', responded_at_ms = 1 WHERE id = 'o_1'");
    offers.expireDue(TEST_NOW + 10_000);
    expect(statusOf("o_1")).toBe("accepted");
  });
});
