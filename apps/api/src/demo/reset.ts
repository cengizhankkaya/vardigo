import { rmSync } from "node:fs";
import { config } from "../bootstrap/config.js";
import { exitOnOldNode } from "../bootstrap/node-version.js";

exitOnOldNode();
const { prepareDatabase } = await import("../bootstrap/database.js");

for (const suffix of ["", "-wal", "-shm"]) {
  rmSync(config.databasePath + suffix, { force: true });
}
prepareDatabase(config.databasePath).close();
console.log("Veritabanı sıfırlandı");
