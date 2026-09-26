import express from "express";
import type { Database } from "./platform/database/connection.js";
import { errorHandler, notFoundHandler } from "./platform/http/error-handler.js";
import { sendOk } from "./platform/http/response.js";

export interface AppDeps {
  db: Database;
}

export function createApp(_deps: AppDeps) {
  const app = express();
  app.use(express.json());

  const api = express.Router();
  api.get("/health", (_req, res) => sendOk(res, { status: "up" }));
  app.use("/api", api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
