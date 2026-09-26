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
