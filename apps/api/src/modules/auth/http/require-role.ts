import type { RequestHandler, Response } from "express";
import { HttpError } from "../../../platform/http/response.js";
import type { Role, User } from "../domain/user.js";
import type { UsersRepository } from "../domain/users-repository.js";

/** Accepts `Authorization: Bearer <token>` only for the given role. */
export function requireRole(users: UsersRepository, role: Role): RequestHandler {
  return (req, res, next) => {
    const header = req.get("authorization");
    if (!header) {
      throw new HttpError(401, "AUTH_REQUIRED", "Giriş yapmanız gerekiyor");
    }
    const match = /^Bearer\s+(\S+)$/i.exec(header);
    const user = match ? users.findByToken(match[1]!) : undefined;
    if (!user) {
      throw new HttpError(401, "INVALID_TOKEN", "Oturum bilgisi geçersiz");
    }
    if (user.role !== role) {
      // 401 rather than the usual 403: the case contract asks for it (BACKEND_PLANI D16).
      throw new HttpError(401, "ROLE_NOT_ALLOWED", "Bu işlem için yetkiniz yok");
    }
    res.locals.user = user;
    next();
  };
}

export function currentUser(res: Response): User {
  return res.locals.user as User;
}
