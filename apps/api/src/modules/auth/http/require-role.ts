import type { RequestHandler, Response } from "express";
import { HttpError } from "../../../platform/http/response.js";
import type { Role, User } from "../domain/user.js";
import type { SqliteUsersRepository } from "../infrastructure/sqlite-users-repository.js";

/** Accepts `Authorization: Bearer <token>` only for the given role. */
export function requireRole(users: SqliteUsersRepository, role: Role): RequestHandler {
  return (req, res, next) => {
    const match = /^Bearer (\S+)$/.exec(req.get("authorization") ?? "");
    const user = match ? users.findByToken(match[1]!) : undefined;
    if (!user) {
      throw new HttpError(401, "UNAUTHORIZED", "Geçerli bir Bearer token gerekli");
    }
    if (user.role !== role) {
      throw new HttpError(401, "ROLE_NOT_ALLOWED", "Bu işlem için yetkiniz yok");
    }
    res.locals.user = user;
    next();
  };
}

export function currentUser(res: Response): User {
  return res.locals.user as User;
}
