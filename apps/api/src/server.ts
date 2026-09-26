import { exitOnOldNode } from "./bootstrap/node-version.js";

exitOnOldNode();
// Loaded after the check: older Node has no node:sqlite and would fail with an unclear error.
await import("./bootstrap/start.js");
