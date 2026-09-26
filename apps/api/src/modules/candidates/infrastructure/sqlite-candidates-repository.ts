import type { Database } from "../../../platform/database/connection.js";
import type { Candidate } from "../domain/candidate.js";
import type { CandidatesRepository } from "../domain/candidates-repository.js";

export class SqliteCandidatesRepository implements CandidatesRepository {
  constructor(private readonly db: Database) {}

  findAll(): Candidate[] {
    return this.db
      .prepare(
        `SELECT id, name, rating, attend, km, km_value, photo, online, score
         FROM candidates ORDER BY seed_order`,
      )
      .all()
      .map((row) => ({
        id: String(row.id),
        name: String(row.name),
        rating: String(row.rating),
        attend: String(row.attend),
        km: String(row.km),
        kmValue: Number(row.km_value),
        photo: String(row.photo),
        online: row.online === 1,
        score: Number(row.score),
      }));
  }
}
