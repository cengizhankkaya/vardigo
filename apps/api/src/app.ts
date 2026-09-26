import express from "express";
import { DEMO_RECIPIENT_USER_ID, demoJob } from "./demo/demo-job.js";
import { candidateLabels } from "./demo/labels.js";
import { authRoutes } from "./modules/auth/http/auth-routes.js";
import { requireRole } from "./modules/auth/http/require-role.js";
import { SqliteUsersRepository } from "./modules/auth/infrastructure/sqlite-users-repository.js";
import { candidatesRoutes } from "./modules/candidates/http/candidates-routes.js";
import { SqliteCandidatesRepository } from "./modules/candidates/infrastructure/sqlite-candidates-repository.js";
import { offersRoutes } from "./modules/offers/http/offers-routes.js";
import { SqliteOffersRepository } from "./modules/offers/infrastructure/sqlite-offers-repository.js";
import type { Database } from "./platform/database/connection.js";
import { errorHandler, notFoundHandler } from "./platform/http/error-handler.js";
import { sendOk } from "./platform/http/response.js";

export interface AppDeps {
  db: Database;
  now?: () => number;
}

export function createApp({ db, now = Date.now }: AppDeps) {
  const users = new SqliteUsersRepository(db);
  const candidates = new SqliteCandidatesRepository(db);
  const offers = new SqliteOffersRepository(db);
  const employerOnly = requireRole(users, "employer");

  const app = express();
  app.disable("x-powered-by");
  app.use(express.json());

  const api = express.Router();
  api.get("/health", (_req, res) => sendOk(res, { status: "up" }));
  api.use("/auth", authRoutes(users));
  api.use("/candidates", candidatesRoutes(candidates, candidateLabels, employerOnly));
  api.use(
    "/offers",
    offersRoutes({ db, offers, candidates, job: demoJob, recipientUserId: DEMO_RECIPIENT_USER_ID, now }, employerOnly),
  );
  app.use("/api", api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
