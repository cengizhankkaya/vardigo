import type { ErrorRequestHandler, RequestHandler } from "express";
import { HttpError, sendError } from "./response.js";

export const notFoundHandler: RequestHandler = (_req, res) => {
  sendError(res, 404, "NOT_FOUND", "Endpoint bulunamadı");
};

/** Errors raised by Express itself (body parser, URL decoding) before our routes run. */
const REQUEST_ERRORS: Record<string, [number, string, string]> = {
  "entity.parse.failed": [400, "INVALID_JSON", "İstek gövdesi geçerli JSON değil"],
  "entity.too.large": [413, "PAYLOAD_TOO_LARGE", "İstek gövdesi çok büyük"],
  "charset.unsupported": [415, "UNSUPPORTED_MEDIA_TYPE", "İstek gövdesi UTF-8 JSON olmalı"],
  "encoding.unsupported": [415, "UNSUPPORTED_MEDIA_TYPE", "İstek gövdesi sıkıştırması desteklenmiyor"],
};

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof HttpError) {
    sendError(res, err.status, err.code, err.message);
    return;
  }
  const known = REQUEST_ERRORS[err?.type];
  if (known) {
    sendError(res, ...known);
    return;
  }
  if (err instanceof URIError) {
    sendError(res, 400, "BAD_REQUEST", "Adres geçersiz karakter içeriyor");
    return;
  }
  console.error(err);
  sendError(res, 500, "INTERNAL_ERROR", "Beklenmeyen bir hata oluştu");
};

/** A body that is sent must be JSON; otherwise it would be silently ignored. */
export const requireJsonBody: RequestHandler = (req, _res, next) => {
  // A chunked body has no Content-Length, so Transfer-Encoding counts as a body too.
  const hasBody = req.get("transfer-encoding") !== undefined || Number(req.get("content-length") ?? 0) > 0;
  if (req.method === "POST" && hasBody && !req.is("application/json")) {
    throw new HttpError(415, "UNSUPPORTED_MEDIA_TYPE", "İstek gövdesi JSON olmalı (Content-Type: application/json)");
  }
  next();
};
