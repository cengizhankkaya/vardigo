import { beforeEach, describe, expect, it } from "vitest";
import { demoJob } from "../src/demo/demo-job.js";
import { getOffer, listOffers, type ListOffersDeps } from "../src/modules/offers/application/list-offers.js";
import { SqliteOffersRepository } from "../src/modules/offers/infrastructure/sqlite-offers-repository.js";
import { sqliteUnitOfWork } from "../src/platform/database/connection.js";
import { createTestApp, TEST_NOW } from "./support/test-app.js";

const HOUR = 3_600_000;

describe("listOffers", () => {
  let db: ReturnType<typeof createTestApp>["db"];
  let deps: ListOffersDeps;
  let now: number;

  beforeEach(() => {
    ({ db } = createTestApp());
    now = TEST_NOW;
    const offers = new SqliteOffersRepository(db);
    deps = { unitOfWork: sqliteUnitOfWork(db), offers, now: () => now };
    offers.insert({
      id: "o_new",
      recipientUserId: "u_worker",
      candidateId: "w_merve",
      job: demoJob,
      createdAtMs: TEST_NOW + 1,
    });
  });

  const ids = (filter: "pending" | "answered" | "expired") =>
    listOffers(deps, "u_worker", filter).offers.map((o) => o.id);

  it("lists pending offers newest first, then in seed order", () => {
    expect(ids("pending")).toEqual(["o_new", "o_garson", "o_barista", "o_komi"]);
    expect(listOffers(deps, "u_worker", "pending").pendingCount).toBe(4);
  });

  it("puts accepted and rejected offers in the answered tab", () => {
    db.exec(`UPDATE offers SET status = 'accepted', responded_at_ms = ${TEST_NOW} WHERE id = 'o_garson'`);
    db.exec(`UPDATE offers SET status = 'rejected', responded_at_ms = ${TEST_NOW} WHERE id = 'o_komi'`);
    expect(ids("answered")).toEqual(["o_garson", "o_komi"]);
    expect(listOffers(deps, "u_worker", "pending").pendingCount).toBe(2);
  });

  it("moves offers past expiresAt to the expired tab", () => {
    now = TEST_NOW + 18 * HOUR;
    expect(ids("expired")).toEqual(["o_komi"]);
    expect(ids("pending")).toEqual(["o_new", "o_garson", "o_barista"]);
  });

  it("only shows the recipient's own offers", () => {
    expect(listOffers(deps, "u_employer", "pending")).toMatchObject({ pendingCount: 0, offers: [] });
    expect(getOffer(deps, "u_employer", "o_garson").offer).toBeUndefined();
  });

  it("gets one offer with its current status", () => {
    now = TEST_NOW + 18 * HOUR;
    expect(getOffer(deps, "u_worker", "o_komi").offer?.status).toBe("expired");
    expect(getOffer(deps, "u_worker", "o_missing").offer).toBeUndefined();
  });
});
