import { describe, expect, it } from "vitest";
import { formatRemain, statusesFor } from "../src/modules/offers/domain/offer.js";

const MINUTE = 60_000;

describe("formatRemain", () => {
  it("formats hours and minutes, rounding down", () => {
    expect(formatRemain((21 * 60 + 32) * MINUTE, 0)).toBe("21 saat 32 dakika");
    expect(formatRemain(90 * MINUTE + 59_999, 0)).toBe("1 saat 30 dakika");
    expect(formatRemain(59_999, 0)).toBe("0 saat 0 dakika");
  });

  it("does not go below zero after expiry", () => {
    expect(formatRemain(0, 5 * MINUTE)).toBe("0 saat 0 dakika");
  });
});

describe("statusesFor", () => {
  it("maps the answered tab to accepted and rejected", () => {
    expect(statusesFor("answered")).toEqual(["accepted", "rejected"]);
    expect(statusesFor("pending")).toEqual(["pending"]);
    expect(statusesFor("expired")).toEqual(["expired"]);
  });
});
