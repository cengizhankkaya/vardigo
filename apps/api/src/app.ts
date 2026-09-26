import express from "express";
import { authRoutes } from "./modules/auth/http/auth-routes.js";
import { SqliteUsersRepository } from "./modules/auth/infrastructure/sqlite-users-repository.js";
import type { Database } from "./platform/database/connection.js";
import { errorHandler, notFoundHandler } from "./platform/http/error-handler.js";
import { sendOk } from "./platform/http/response.js";

export interface AppDeps {
  db: Database;
}

export function createApp({ db }: AppDeps) {
  const users = new SqliteUsersRepository(db);

  const app = express();
  app.use(express.json());

  const api = express.Router();
  api.get("/health", (_req, res) => sendOk(res, { status: "up" }));
  api.use("/auth", authRoutes(users));
  app.use("/api", api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
