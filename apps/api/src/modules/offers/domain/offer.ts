export const OFFER_STATUSES = ["pending", "accepted", "rejected", "expired"] as const;

export type OfferStatus = (typeof OFFER_STATUSES)[number];

/** Job details copied into each offer when it is sent. */
export interface OfferJob {
  title: string;
  place: string;
  pay: string;
  payValue: number;
  logo: string;
  district: string;
  when: string;
  validForMs: number;
}

export interface NewOffer {
  id: string;
  recipientUserId: string;
  candidateId: string;
  job: OfferJob;
  createdAtMs: number;
}

export const OFFER_STATUS_FILTERS = ["pending", "answered", "expired"] as const;

export type OfferStatusFilter = (typeof OFFER_STATUS_FILTERS)[number];

/** The "answered" tab covers both decisions. */
export function statusesFor(filter: OfferStatusFilter): OfferStatus[] {
  return filter === "answered" ? ["accepted", "rejected"] : [filter];
}

/** "21 saat 32 dakika"; never negative. */
export function formatRemain(expiresAtMs: number, nowMs: number): string {
  const totalMinutes = Math.floor(Math.max(0, expiresAtMs - nowMs) / 60_000);
  return `${Math.floor(totalMinutes / 60)} saat ${totalMinutes % 60} dakika`;
}
