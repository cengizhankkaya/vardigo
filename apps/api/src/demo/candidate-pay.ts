import type { CandidatePay } from "../modules/candidates/domain/candidate.js";

/**
 * Pay line on the candidate cards. The case seed has no pay data: the first four
 * are read from the reference design (every card shows ₺25.000 / ay), the rest are
 * demo values.
 */
export const candidatePay: Record<string, CandidatePay> = {
  w_merve: { expectedPay: 25000, payCompatible: true },
  w_derya: { expectedPay: 25000, payCompatible: false },
  w_ayse: { expectedPay: 25000, payCompatible: true },
  w_ferhat: { expectedPay: 25000, payCompatible: false },
  w_elif: { expectedPay: 24000, payCompatible: true },
  w_burak: { expectedPay: 27000, payCompatible: true },
  w_zeynep: { expectedPay: 30000, payCompatible: false },
  w_emre: { expectedPay: 22000, payCompatible: true },
  w_selin: { expectedPay: 26000, payCompatible: true },
  w_can: { expectedPay: 32000, payCompatible: false },
  w_irem: { expectedPay: 23000, payCompatible: true },
  w_mert: { expectedPay: 28000, payCompatible: false },
};
