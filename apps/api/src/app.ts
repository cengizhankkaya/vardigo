import express from "express";
import { candidateLabels } from "./demo/labels.js";
import { authRoutes } from "./modules/auth/http/auth-routes.js";
import { requireRole } from "./modules/auth/http/require-role.js";
import { SqliteUsersRepository } from "./modules/auth/infrastructure/sqlite-users-repository.js";
import { candidatesRoutes } from "./modules/candidates/http/candidates-routes.js";
import { SqliteCandidatesRepository } from "./modules/candidates/infrastructure/sqlite-candidates-repository.js";
import type { Database } from "./platform/database/connection.js";
import { errorHandler, notFoundHandler } from "./platform/http/error-handler.js";
import { sendOk } from "./platform/http/response.js";

export interface AppDeps {
  db: Database;
}

export function createApp({ db }: AppDeps) {
  const users = new SqliteUsersRepository(db);
  const candidates = new SqliteCandidatesRepository(db);
  const employerOnly = requireRole(users, "employer");

  const app = express();
  app.disable("x-powered-by");
  app.use(express.json());

  const api = express.Router();
  api.get("/health", (_req, res) => sendOk(res, { status: "up" }));
  api.use("/auth", authRoutes(users));
  api.use("/candidates", candidatesRoutes(candidates, candidateLabels, employerOnly));
  app.use("/api", api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
