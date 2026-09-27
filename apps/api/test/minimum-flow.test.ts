import request from "supertest";
import { describe, expect, it } from "vitest";
import { createApp } from "../src/app.js";
import { seedDatabase } from "../src/demo/seed.js";
import { openDatabase } from "../src/platform/database/connection.js";
import { migrate } from "../src/platform/database/migrations.js";
import { TEST_NOW } from "./support/test-app.js";
import { tempDbPath } from "./support/temp-db.js";

/** Starts the app on a database file, the way the server does. */
function start(path: string) {
  const db = openDatabase(path);
  migrate(db);
  seedDatabase(db, TEST_NOW);
  return { app: createApp({ db, now: () => TEST_NOW + 60_000 }), db };
}

const ids = (res: request.Response) => res.body.data.offers.map((o: { id: string }) => o.id);

/** "MİNİMUM TEST" from the case backend spec. */
describe("case minimum flow", () => {
  it("runs all six steps and survives a restart", async () => {
    const path = tempDbPath();
    const first = start(path);
    const api = request(first.app);

    // 1. employer login → GET /candidates → 12 people
    const employer = await api.post("/api/auth/login").send({ role: "employer" });
    const employerAuth = `Bearer ${employer.body.data.token}`;
    const candidates = await api.get("/api/candidates").set("Authorization", employerAuth);
    expect(candidates.body.data.candidates).toHaveLength(12);

    // 2. select Merve + Derya → POST /offers
    const sent = await api
      .post("/api/offers")
      .set("Authorization", employerAuth)
      .send({ workerIds: ["w_merve", "w_derya"] });
    expect(sent.status).toBe(201);
    const [merveOffer, deryaOffer] = sent.body.data.created.map((o: { id: string }) => o.id);

    // 3. worker login → GET /offers?status=pending → those two + seed
    const worker = await api.post("/api/auth/login").send({ role: "worker" });
    const workerAuth = `Bearer ${worker.body.data.token}`;
    const pending = await api.get("/api/offers?status=pending").set("Authorization", workerAuth);
    expect(ids(pending)).toEqual([merveOffer, deryaOffer, "o_garson", "o_barista", "o_komi"]);

    // 4. accept one, reject one
    expect((await api.post(`/api/offers/${merveOffer}/accept`).set("Authorization", workerAuth)).status).toBe(200);
    expect((await api.post(`/api/offers/${deryaOffer}/reject`).set("Authorization", workerAuth)).status).toBe(200);

    // 5. GET answered → 2 records
    const answered = await api.get("/api/offers?status=answered").set("Authorization", workerAuth);
    expect(answered.body.data.offers.map((o: { id: string; status: string }) => [o.id, o.status])).toEqual([
      [merveOffer, "accepted"],
      [deryaOffer, "rejected"],
    ]);

    // 6. reload → same state, also after a server restart
    first.db.close();
    const second = start(path);
    const afterRestart = await request(second.app).get("/api/offers?status=answered").set("Authorization", workerAuth);
    expect(afterRestart.body.data.offers).toEqual(answered.body.data.offers);
    const pendingAfter = await request(second.app).get("/api/offers").set("Authorization", workerAuth);
    expect(pendingAfter.body.data.pendingCount).toBe(3);
    second.db.close();
  });
});
