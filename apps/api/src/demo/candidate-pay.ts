import type { CandidatePay } from "../modules/candidates/domain/candidate.js";

/**
 * Pay line on the candidate cards. The case seed has no pay data, so these values
 * are read from the reference design (every card shows ₺25.000 / ay).
 */
export const candidatePay: Record<string, CandidatePay> = {
  w_merve: { expectedPay: 25000, payCompatible: true },
  w_derya: { expectedPay: 25000, payCompatible: false },
  w_ayse: { expectedPay: 25000, payCompatible: true },
  w_ferhat: { expectedPay: 25000, payCompatible: false },
};
