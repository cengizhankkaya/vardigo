import { type RequestHandler, Router } from "express";
import { HttpError, sendOk } from "../../../platform/http/response.js";
import { createOffers, type CreateOffersDeps } from "../application/create-offers.js";

const MAX_WORKER_IDS = 100;

function parseWorkerIds(body: unknown): string[] {
  const workerIds: unknown = (body as { workerIds?: unknown } | undefined)?.workerIds;
  if (!Array.isArray(workerIds)) {
    throw new HttpError(400, "VALIDATION_ERROR", "workerIds bir dizi olmalı");
  }
  if (workerIds.length === 0) {
    throw new HttpError(400, "EMPTY_SELECTION", "En az bir personel seçin");
  }
  if (workerIds.length > MAX_WORKER_IDS) {
    throw new HttpError(400, "VALIDATION_ERROR", `En fazla ${MAX_WORKER_IDS} personel seçilebilir`);
  }
  if (!workerIds.every((id) => typeof id === "string" && id.length > 0)) {
    throw new HttpError(400, "VALIDATION_ERROR", "workerIds yalnız dolu metin değerleri içermeli");
  }
  if (new Set(workerIds).size !== workerIds.length) {
    throw new HttpError(400, "DUPLICATE_WORKER_IDS", "Aynı personel birden fazla kez seçilemez");
  }
  return workerIds;
}

export function offersRoutes(createDeps: CreateOffersDeps, employerOnly: RequestHandler): Router {
  const router = Router();

  router.post("/", employerOnly, (req, res) => {
    const result = createOffers(createDeps, parseWorkerIds(req.body));
    switch (result.kind) {
      case "created":
        sendOk(res, { created: result.created }, 201);
        return;
      case "candidate_not_found":
        throw new HttpError(404, "CANDIDATE_NOT_FOUND", `Personel bulunamadı: ${result.workerId}`);
      case "pending_exists":
        throw new HttpError(
          409,
          "OFFER_PENDING_EXISTS",
          `Seçilen personel için açık teklif var: ${result.workerIds.join(", ")}`,
        );
    }
  });

  return router;
}
