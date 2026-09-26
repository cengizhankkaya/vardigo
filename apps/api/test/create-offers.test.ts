import { beforeEach, describe, expect, it } from "vitest";
import { demoJob, DEMO_RECIPIENT_USER_ID } from "../src/demo/demo-job.js";
import { SqliteCandidatesRepository } from "../src/modules/candidates/infrastructure/sqlite-candidates-repository.js";
import { createOffers, type CreateOffersDeps } from "../src/modules/offers/application/create-offers.js";
import { SqliteOffersRepository } from "../src/modules/offers/infrastructure/sqlite-offers-repository.js";
import { createTestApp, TEST_NOW } from "./support/test-app.js";

describe("createOffers", () => {
  let db: ReturnType<typeof createTestApp>["db"];
  let deps: CreateOffersDeps;
  let now: number;
  let seq: number;

  beforeEach(() => {
    ({ db } = createTestApp());
    now = TEST_NOW;
    seq = 0;
    deps = {
      db,
      offers: new SqliteOffersRepository(db),
      candidates: new SqliteCandidatesRepository(db),
      job: demoJob,
      recipientUserId: DEMO_RECIPIENT_USER_ID,
      now: () => now,
      newId: () => `o_test_${++seq}`,
    };
  });

  const newOfferCount = () => db.prepare("SELECT COUNT(*) AS n FROM offers WHERE candidate_id IS NOT NULL").get()?.n;

  it("creates one pending offer per candidate in request order", () => {
    expect(createOffers(deps, ["w_merve", "w_derya"])).toEqual({
      kind: "created",
      created: [
        { id: "o_test_1", workerId: "w_merve", status: "pending" },
        { id: "o_test_2", workerId: "w_derya", status: "pending" },
      ],
    });
    const row = db.prepare("SELECT recipient_user_id, title, expires_at_ms FROM offers WHERE id = 'o_test_1'").get();
    expect(row).toEqual({ recipient_user_id: "u_worker", title: "Garson", expires_at_ms: TEST_NOW + demoJob.validForMs });
  });

  it("is not blocked by the seed offers", () => {
    expect(createOffers(deps, ["w_merve"]).kind).toBe("created");
  });

  it("rejects the whole batch when a candidate is unknown", () => {
    expect(createOffers(deps, ["w_merve", "u_worker"])).toEqual({ kind: "candidate_not_found", workerId: "u_worker" });
    expect(newOfferCount()).toBe(0);
  });

  it("rejects the whole batch when one candidate already has a pending offer", () => {
    createOffers(deps, ["w_merve"]);
    expect(createOffers(deps, ["w_derya", "w_merve"])).toEqual({ kind: "pending_exists", workerIds: ["w_merve"] });
    expect(newOfferCount()).toBe(1);
  });

  it("reports an unknown candidate before a pending conflict", () => {
    createOffers(deps, ["w_merve"]);
    expect(createOffers(deps, ["w_merve", "w_nope"]).kind).toBe("candidate_not_found");
  });

  it("allows a new offer once the previous one has expired", () => {
    createOffers(deps, ["w_merve"]);
    now = TEST_NOW + demoJob.validForMs;
    expect(createOffers(deps, ["w_merve"]).kind).toBe("created");
    expect(db.prepare("SELECT status FROM offers WHERE id = 'o_test_1'").get()?.status).toBe("expired");
  });

  it("keeps the expiry update even when the request ends in a conflict", () => {
    createOffers(deps, ["w_merve"]);
    now = TEST_NOW + 1000;
    createOffers(deps, ["w_derya"]);
    now = TEST_NOW + demoJob.validForMs;
    expect(createOffers(deps, ["w_derya"]).kind).toBe("pending_exists");
    expect(db.prepare("SELECT status FROM offers WHERE id = 'o_test_1'").get()?.status).toBe("expired");
  });

  it("allows a new offer after the previous one was answered", () => {
    createOffers(deps, ["w_merve"]);
    db.exec(`UPDATE offers SET status = 'rejected', responded_at_ms = ${TEST_NOW} WHERE id = 'o_test_1'`);
    expect(createOffers(deps, ["w_merve"]).kind).toBe("created");
  });
});
