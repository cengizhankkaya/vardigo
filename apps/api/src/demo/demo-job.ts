import type { OfferJob } from "../modules/offers/domain/offer.js";

/** The case has a single job; every new offer is a copy of it. */
export const demoJob: OfferJob = {
  title: "Garson",
  place: "Zarif Cheff Restaurant",
  pay: "45.000",
  payValue: 45000,
  logo: "logos/zarif.svg",
  district: "Kadıköy",
  when: "16 Ağu · 12:00 - 16:00",
  validForMs: (21 * 60 + 32) * 60_000,
};

/** Extra fields shown on the offer detail; the case gives one fixed example. */
export const demoOfferDetails = { city: "İstanbul", note: "Şube: Sinanpaşa Mah." };

/** The case has one job seeker account; offers to any candidate land in its inbox. */
export const DEMO_RECIPIENT_USER_ID = "u_worker";
