import type { RequestHandler } from "express";

const LOCAL_ORIGIN = /^https?:\/\/(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$/;

/** Lets browser pages served from this machine call the API; other origins get no CORS headers. */
export const localhostCors: RequestHandler = (req, res, next) => {
  const origin = req.get("origin");
  if (origin && LOCAL_ORIGIN.test(origin)) {
    res.set({
      "Access-Control-Allow-Origin": origin,
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Authorization, Content-Type",
      "Access-Control-Max-Age": "600",
    });
  }
  res.vary("Origin");
  if (req.method === "OPTIONS") {
    res.sendStatus(204);
    return;
  }
  next();
};
