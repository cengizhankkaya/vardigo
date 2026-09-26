import { beforeEach, describe, expect, it } from "vitest";
import { respondToOffer, type RespondToOfferDeps } from "../src/modules/offers/application/respond-to-offer.js";
import { SqliteOffersRepository } from "../src/modules/offers/infrastructure/sqlite-offers-repository.js";
import { openDatabase, sqliteUnitOfWork } from "../src/platform/database/connection.js";
import { createTestApp, TEST_NOW } from "./support/test-app.js";

const HOUR = 3_600_000;
const KOMI_EXPIRES = TEST_NOW + 18 * HOUR;

describe("respondToOffer", () => {
  let db: ReturnType<typeof createTestApp>["db"];
  let deps: RespondToOfferDeps;
  let now: number;

  beforeEach(() => {
    ({ db } = createTestApp());
    now = TEST_NOW;
    deps = { unitOfWork: sqliteUnitOfWork(db), offers: new SqliteOffersRepository(db), now: () => now };
  });

  const row = (id: string) => db.prepare("SELECT status, responded_at_ms FROM offers WHERE id = ?").get(id);

  it("accepts a pending offer and stores when it happened", () => {
    const result = respondToOffer(deps, "u_worker", "o_garson", "accepted");
    expect(result).toMatchObject({ kind: "responded", offer: { id: "o_garson", status: "accepted" } });
    expect(row("o_garson")).toEqual({ status: "accepted", responded_at_ms: TEST_NOW });
  });

  it("rejects a pending offer", () => {
    expect(respondToOffer(deps, "u_worker", "o_barista", "rejected").kind).toBe("responded");
    expect(row("o_barista")?.status).toBe("rejected");
  });

  it("does not change an answered offer", () => {
    respondToOffer(deps, "u_worker", "o_garson", "accepted");
    expect(respondToOffer(deps, "u_worker", "o_garson", "rejected")).toEqual({ kind: "already_answered" });
    expect(respondToOffer(deps, "u_worker", "o_garson", "accepted")).toEqual({ kind: "already_answered" });
    expect(row("o_garson")?.status).toBe("accepted");
  });

  it("keeps an answered offer answered after its time passes", () => {
    respondToOffer(deps, "u_worker", "o_komi", "accepted");
    now = KOMI_EXPIRES + HOUR;
    expect(respondToOffer(deps, "u_worker", "o_komi", "rejected")).toEqual({ kind: "already_answered" });
    expect(row("o_komi")?.status).toBe("accepted");
  });

  it("refuses at exactly expiresAt and commits the expired status", () => {
    now = KOMI_EXPIRES - 1;
    expect(respondToOffer(deps, "u_worker", "o_barista", "accepted").kind).toBe("responded");

    now = KOMI_EXPIRES;
    expect(respondToOffer(deps, "u_worker", "o_komi", "accepted")).toEqual({ kind: "expired" });
    expect(row("o_komi")).toEqual({ status: "expired", responded_at_ms: null });
    expect(respondToOffer(deps, "u_worker", "o_komi", "rejected")).toEqual({ kind: "expired" });
  });

  it("returns not_found for unknown ids and other users' offers", () => {
    expect(respondToOffer(deps, "u_worker", "o_missing", "accepted")).toEqual({ kind: "not_found" });
    expect(respondToOffer(deps, "u_employer", "o_garson", "accepted")).toEqual({ kind: "not_found" });
    expect(row("o_garson")?.status).toBe("pending");
  });

  it("lets only the first of two connections answer", () => {
    const path = String(db.prepare("PRAGMA database_list").get()?.file);
    const other = openDatabase(path);
    const otherDeps = { unitOfWork: sqliteUnitOfWork(other), offers: new SqliteOffersRepository(other), now: () => now };

    expect(respondToOffer(deps, "u_worker", "o_garson", "accepted").kind).toBe("responded");
    expect(respondToOffer(otherDeps, "u_worker", "o_garson", "rejected")).toEqual({ kind: "already_answered" });
    other.close();
    expect(row("o_garson")?.status).toBe("accepted");
  });
});
