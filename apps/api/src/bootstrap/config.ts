import { fileURLToPath } from "node:url";

const defaultDatabasePath = fileURLToPath(new URL("../../data/vardigo.db", import.meta.url));

export const config = {
  port: Number(process.env.PORT ?? 3000),
  databasePath: process.env.DATABASE_PATH ?? defaultDatabasePath,
};
