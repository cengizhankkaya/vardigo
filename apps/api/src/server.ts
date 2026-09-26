import { createApp } from "./app.js";
import { config } from "./bootstrap/config.js";
import { prepareDatabase } from "./bootstrap/database.js";

const db = prepareDatabase(config.databasePath);

createApp({ db }).listen(config.port, config.host, () => {
  console.log(`API http://${config.host}:${config.port}/api`);
});
