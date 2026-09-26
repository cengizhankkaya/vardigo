export const ROLES = ["employer", "worker"] as const;

export type Role = (typeof ROLES)[number];

export interface User {
  id: string;
  role: Role;
  name: string;
  token: string;
}

export function isRole(value: unknown): value is Role {
  return typeof value === "string" && (ROLES as readonly string[]).includes(value);
}
