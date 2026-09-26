import { fileURLToPath } from "node:url";

const defaultDatabasePath = fileURLToPath(new URL("../../data/vardigo.db", import.meta.url));

export const config = {
  port: Number(process.env.PORT ?? 3000),
  // Only this machine by default; set HOST=0.0.0.0 to reach it from a phone on the same network.
  host: process.env.HOST ?? "127.0.0.1",
  databasePath: process.env.DATABASE_PATH ?? defaultDatabasePath,
};
