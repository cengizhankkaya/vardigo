import type { Response } from "express";

export class HttpError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
  }
}

export function sendOk(res: Response, data: unknown, status = 200): void {
  res.status(status).json({ ok: true, data });
}

export function sendError(res: Response, status: number, code: string, message: string): void {
  res.status(status).json({ ok: false, error: { code, message } });
}
