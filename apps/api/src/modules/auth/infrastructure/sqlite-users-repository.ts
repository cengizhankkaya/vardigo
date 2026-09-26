import type { Database } from "../../../platform/database/connection.js";
import type { Role, User } from "../domain/user.js";

export class SqliteUsersRepository {
  constructor(private readonly db: Database) {}

  findByRole(role: Role): User | undefined {
    return this.db.prepare("SELECT id, role, name, token FROM users WHERE role = ? LIMIT 1").get(role) as
      | User
      | undefined;
  }

  findByToken(token: string): User | undefined {
    return this.db.prepare("SELECT id, role, name, token FROM users WHERE token = ?").get(token) as
      | User
      | undefined;
  }
}
