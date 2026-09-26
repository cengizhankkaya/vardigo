import { HttpError } from "./response.js";

/** Reads an optional query value that must be one of `allowed`. */
export function optionalQuery<T extends string>(value: unknown, name: string, allowed: readonly T[]): T | undefined {
  if (value === undefined) return undefined;
  if (typeof value === "string" && (allowed as readonly string[]).includes(value)) return value as T;
  throw new HttpError(400, "VALIDATION_ERROR", `${name} şunlardan biri olmalı: ${allowed.join(", ")}`);
}
