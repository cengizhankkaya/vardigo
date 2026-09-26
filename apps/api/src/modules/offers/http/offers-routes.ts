import { type RequestHandler, Router } from "express";
import { optionalQuery } from "../../../platform/http/query.js";
import { HttpError, sendOk } from "../../../platform/http/response.js";
import { currentUser } from "../../auth/http/require-role.js";
import { createOffers, type CreateOffersDeps } from "../application/create-offers.js";
import { getOffer, listOffers, type ListOffersDeps } from "../application/list-offers.js";
import { type Decision, respondToOffer, type RespondToOfferDeps } from "../application/respond-to-offer.js";
import { formatRemain, type Offer, OFFER_SORTS, OFFER_STATUS_FILTERS } from "../domain/offer.js";

const MAX_WORKER_IDS = 100;

export interface OffersRoutesDeps {
  create: CreateOffersDeps;
  list: ListOffersDeps;
  respond: RespondToOfferDeps;
  pendingCountLabel: number;
  detailExtras: { city: string; note: string };
  employerOnly: RequestHandler;
  workerOnly: RequestHandler;
}

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

/** Accept/reject take no input; an empty body or `{}` is fine, anything else is a mistake. */
function assertNoBody(body: unknown): void {
  const isEmptyObject =
    typeof body === "object" && body !== null && !Array.isArray(body) && Object.keys(body).length === 0;
  if (body !== undefined && !isEmptyObject) {
    throw new HttpError(400, "VALIDATION_ERROR", "Bu istek gövde almaz");
  }
}

function toDto(offer: Offer, now: number) {
  return {
    id: offer.id,
    title: offer.title,
    place: offer.place,
    pay: offer.pay,
    logo: `/assets/${offer.logo}`,
    district: offer.district,
    when: offer.when,
    status: offer.status,
    remain: formatRemain(offer.expiresAtMs, now),
    expiresAt: new Date(offer.expiresAtMs).toISOString(),
  };
}

export function offersRoutes(deps: OffersRoutesDeps): Router {
  const router = Router();

  router.post("/", deps.employerOnly, (req, res) => {
    const result = createOffers(deps.create, parseWorkerIds(req.body));
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

  router.get("/", deps.workerOnly, (req, res) => {
    const status = optionalQuery(req.query.status, "status", OFFER_STATUS_FILTERS) ?? "pending";
    const sort = optionalQuery(req.query.sort, "sort", OFFER_SORTS);
    const listing = listOffers(deps.list, currentUser(res).id, status, sort);
    sendOk(res, {
      pendingCount: listing.pendingCount,
      pendingCountLabel: deps.pendingCountLabel,
      offers: listing.offers.map((offer) => toDto(offer, listing.now)),
    });
  });

  router.get("/:id", deps.workerOnly, (req, res) => {
    const { now, offer } = getOffer(deps.list, currentUser(res).id, req.params.id as string);
    if (!offer) {
      throw new HttpError(404, "OFFER_NOT_FOUND", "Teklif bulunamadı");
    }
    sendOk(res, { ...toDto(offer, now), ...deps.detailExtras });
  });

  const respond = (decision: Decision): RequestHandler => (req, res) => {
    assertNoBody(req.body);
    const result = respondToOffer(deps.respond, currentUser(res).id, req.params.id as string, decision);
    switch (result.kind) {
      case "responded":
        sendOk(res, toDto(result.offer, result.now));
        return;
      case "not_found":
        throw new HttpError(404, "OFFER_NOT_FOUND", "Teklif bulunamadı");
      case "expired":
        throw new HttpError(409, "OFFER_EXPIRED", "Teklifin süresi doldu");
      case "already_answered":
        throw new HttpError(409, "OFFER_STATE", "Bu teklif daha önce yanıtlandı");
    }
  };

  router.post("/:id/accept", deps.workerOnly, respond("accepted"));
  router.post("/:id/reject", deps.workerOnly, respond("rejected"));

  return router;
}
