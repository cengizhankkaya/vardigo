/**
 * Port: runs [work] as one atomic unit, so every change inside commits or none
 * does. Use cases ask for it; the database adapter provides it
 * (`sqliteUnitOfWork`). Synchronous because `node:sqlite` is.
 */
export type UnitOfWork = <T>(work: () => T) => T;
