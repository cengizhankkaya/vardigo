import express from "express";
import { errorHandler, notFoundHandler } from "./platform/http/error-handler.js";
import { sendOk } from "./platform/http/response.js";

export function createApp() {
  const app = express();
  app.use(express.json());

  const api = express.Router();
  api.get("/health", (_req, res) => sendOk(res, { status: "up" }));
  app.use("/api", api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
