import { createApp } from "./app.js";
import { config } from "./bootstrap/config.js";
import { prepareDatabase } from "./bootstrap/database.js";

const db = prepareDatabase(config.databasePath);

createApp({ db }).listen(config.port, () => {
  console.log(`API http://localhost:${config.port}/api`);
});
