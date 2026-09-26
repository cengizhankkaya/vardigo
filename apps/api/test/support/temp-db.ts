import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { afterEach } from "vitest";

const dirs: string[] = [];

afterEach(() => {
  for (const dir of dirs.splice(0)) rmSync(dir, { recursive: true, force: true });
});

export function tempDbPath(): string {
  const dir = mkdtempSync(join(tmpdir(), "vardigo-api-"));
  dirs.push(dir);
  return join(dir, "test.db");
}
