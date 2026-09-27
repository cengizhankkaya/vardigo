import { fileURLToPath } from "node:url";
import express from "express";
import swaggerUi from "swagger-ui-express";
import { openApiDocument } from "./swagger/openapi.js";
import { candidatePay } from "./demo/candidate-pay.js";
import { DEMO_RECIPIENT_USER_ID, demoJob, demoOfferDetails } from "./demo/demo-job.js";
import { candidateSelectedHint, pendingCountLabel } from "./demo/labels.js";
import { authRoutes } from "./modules/auth/http/auth-routes.js";
import { requireRole } from "./modules/auth/http/require-role.js";
import { SqliteUsersRepository } from "./modules/auth/infrastructure/sqlite-users-repository.js";
import { candidatesRoutes } from "./modules/candidates/http/candidates-routes.js";
import { SqliteCandidatesRepository } from "./modules/candidates/infrastructure/sqlite-candidates-repository.js";
import { offersRoutes } from "./modules/offers/http/offers-routes.js";
import { SqliteOffersRepository } from "./modules/offers/infrastructure/sqlite-offers-repository.js";
import { type Database, sqliteUnitOfWork } from "./platform/database/connection.js";
import { localhostCors } from "./platform/http/cors.js";
import { errorHandler, notFoundHandler, requireJsonBody } from "./platform/http/error-handler.js";
import { sendOk } from "./platform/http/response.js";

export interface AppDeps {
  db: Database;
  now?: () => number;
}

/** Case photos and logos; the API returns them as /assets/photos/... and /assets/logos/... */
export const ASSETS_DIR = fileURLToPath(new URL("../public/assets", import.meta.url));

export function createApp({ db, now = Date.now }: AppDeps) {
  const users = new SqliteUsersRepository(db);
  const candidates = new SqliteCandidatesRepository(db);
  const offers = new SqliteOffersRepository(db);
  const unitOfWork = sqliteUnitOfWork(db);
  const employerOnly = requireRole(users, "employer");
  const workerOnly = requireRole(users, "worker");

  const app = express();
  app.disable("x-powered-by");
  app.use(localhostCors);
  app.use(requireJsonBody);
  app.use(express.json());

  app.use("/assets", express.static(ASSETS_DIR, { index: false, dotfiles: "ignore", maxAge: "1h" }));

  app.get("/api/openapi.json", (_req, res) => {
    res.json(openApiDocument);
  });
  app.use(
    "/api/docs",
    swaggerUi.serve,
    swaggerUi.setup(openApiDocument, {
      customSiteTitle: "Vardigo API",
      swaggerOptions: { persistAuthorization: true },
    }),
  );

  const api = express.Router();
  api.get("/health", (_req, res) => sendOk(res, { status: "up" }));
  api.use("/auth", authRoutes(users));
  api.use(
    "/candidates",
    candidatesRoutes({ unitOfWork, candidates, offers, now }, candidateSelectedHint, candidatePay, employerOnly),
  );
  api.use(
    "/offers",
    offersRoutes({
      create: { unitOfWork, offers, candidates, job: demoJob, recipientUserId: DEMO_RECIPIENT_USER_ID, now },
      list: { unitOfWork, offers, now },
      respond: { unitOfWork, offers, now },
      pendingCountLabel,
      detailExtras: demoOfferDetails,
      employerOnly,
      workerOnly,
    }),
  );
  app.use("/api", api);

  app.use(notFoundHandler);
  app.use(errorHandler);
  return app;
}
