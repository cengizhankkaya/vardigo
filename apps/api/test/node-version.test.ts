import { describe, expect, it } from "vitest";
import { nodeVersionProblem } from "../src/bootstrap/node-version.js";

describe("nodeVersionProblem", () => {
  it("accepts Node 24 and newer", () => {
    expect(nodeVersionProblem("24.0.0")).toBeUndefined();
    expect(nodeVersionProblem("25.2.1")).toBeUndefined();
  });

  it("explains what to do on older Node", () => {
    expect(nodeVersionProblem("20.11.1")).toBe(
      "Node.js 24 veya üstü gerekli; bu bilgisayarda 20.11.1 var. https://nodejs.org adresinden LTS sürümünü kurun.",
    );
  });
});
