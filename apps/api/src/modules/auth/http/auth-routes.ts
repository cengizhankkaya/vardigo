import { Router } from "express";
import { HttpError, sendOk } from "../../../platform/http/response.js";
import { isRole } from "../domain/user.js";
import type { SqliteUsersRepository } from "../infrastructure/sqlite-users-repository.js";

export function authRoutes(users: SqliteUsersRepository): Router {
  const router = Router();

  router.post("/login", (req, res) => {
    const role: unknown = req.body?.role;
    if (!isRole(role)) {
      throw new HttpError(400, "VALIDATION_ERROR", "role alanı 'employer' veya 'worker' olmalı");
    }
    const user = users.findByRole(role);
    if (!user) {
      throw new HttpError(404, "USER_NOT_FOUND", "Bu rol için demo hesabı bulunamadı");
    }
    sendOk(res, { token: user.token, role: user.role });
  });

  return router;
}
