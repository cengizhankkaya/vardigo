import type { ErrorRequestHandler, RequestHandler } from "express";
import { HttpError, sendError } from "./response.js";

export const notFoundHandler: RequestHandler = (_req, res) => {
  sendError(res, 404, "NOT_FOUND", "Endpoint bulunamadı");
};

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof HttpError) {
    sendError(res, err.status, err.code, err.message);
    return;
  }
  if (err?.type === "entity.parse.failed") {
    sendError(res, 400, "INVALID_JSON", "İstek gövdesi geçerli JSON değil");
    return;
  }
  console.error(err);
  sendError(res, 500, "INTERNAL_ERROR", "Beklenmeyen bir hata oluştu");
};
