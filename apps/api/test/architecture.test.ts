import { readdirSync, readFileSync } from "node:fs";
import { dirname, join, relative, resolve } from "node:path";
import { describe, expect, it } from "vitest";

/**
 * Import rules of the layers, checked on every file in src/. Dependencies
 * point inward: http → application → domain ← infrastructure. Use cases see
 * ports (`…Repository`, `UnitOfWork`); only the composition root (`app.ts`),
 * `bootstrap/` and `demo/` know the SQLite adapters.
 */
const SRC = resolve(import.meta.dirname, "../src");

interface Source {
  path: string;
  module?: string;
  layer?: string;
  imports: { spec: string; path?: string }[];
}

function sources(dir = SRC): Source[] {
  return readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) return sources(full);
    if (!entry.name.endsWith(".ts")) return [];
    const path = relative(SRC, full);
    const [, module, layer] = /^modules\/([^/]+)\/([^/]+)\//.exec(path) ?? [];
    const text = readFileSync(full, "utf8");
    const imports = [...text.matchAll(/^(?:import|export)\b[^;]*?\bfrom\s+"([^"]+)"/gms)].map(([, spec]) => ({
      spec: spec!,
      path: spec!.startsWith(".") ? relative(SRC, resolve(dirname(full), spec!)).replace(/\.js$/, ".ts") : undefined,
    }));
    return [{ path, module, layer, imports }];
  });
}

const files = sources();

function check(applies: (s: Source) => boolean, rule: (s: Source, i: Source["imports"][number]) => string | undefined) {
  return files
    .filter(applies)
    .flatMap((s) => s.imports.flatMap((i) => (rule(s, i) ? [`${s.path} → ${i.spec}: ${rule(s, i)}`] : [])));
}

const layerOf = (path: string) => /^modules\/[^/]+\/([^/]+)\//.exec(path)?.[1];

describe("layer rules", () => {
  it("finds every layer", () => {
    for (const layer of ["domain", "application", "infrastructure", "http"]) {
      expect(files.some((s) => s.layer === layer), layer).toBe(true);
    }
  });

  it("domain imports only its own module's domain", () => {
    const problems = check(
      (s) => s.layer === "domain",
      (s, i) => (i.path?.startsWith(`modules/${s.module}/domain/`) ? undefined : "domain stays plain TypeScript"),
    );
    expect(problems).toEqual([]);
  });

  it("application imports domain ports and the unit of work, never a database", () => {
    const problems = check(
      (s) => s.layer === "application",
      (s, i) => {
        if (i.spec.startsWith("node:")) return i.spec === "node:sqlite" ? "no database driver" : undefined;
        if (!i.path) return "application uses no packages";
        if (i.path === "platform/unit-of-work.ts") return undefined;
        if (layerOf(i.path) === "domain") return undefined;
        if (i.path.startsWith(`modules/${s.module}/application/`)) return undefined;
        return "application imports only domain ports and platform/unit-of-work";
      },
    );
    expect(problems).toEqual([]);
  });

  it("infrastructure implements its own domain's ports and nothing above them", () => {
    const problems = check(
      (s) => s.layer === "infrastructure",
      (s, i) => {
        if (!i.path) return undefined;
        if (i.path.startsWith(`modules/${s.module}/domain/`) || i.path.startsWith("platform/")) return undefined;
        return "infrastructure imports only its domain and platform";
      },
    );
    expect(problems).toEqual([]);
  });

  it("only the composition root, bootstrap and demo know the adapters and the database", () => {
    const wiring = (s: Source) => s.path === "app.ts" || /^(bootstrap|demo)\//.test(s.path);
    const problems = check(
      (s) => !wiring(s) && s.layer !== "infrastructure" && !s.path.startsWith("platform/database/"),
      (_, i) =>
        i.path && (layerOf(i.path) === "infrastructure" || i.path.startsWith("platform/database/"))
          ? "reach adapters through ports"
          : undefined,
    );
    expect(problems).toEqual([]);
  });
});
