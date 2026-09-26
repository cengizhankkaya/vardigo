import type { Role, User } from "./user.js";

/** Port: the demo accounts. */
export interface UsersRepository {
  findByRole(role: Role): User | undefined;
  findByToken(token: string): User | undefined;
}
