import 'candidate_offer_status.dart';

class Candidate {
  const Candidate({
    required this.id,
    required this.name,
    required this.rating,
    required this.attendance,
    required this.distance,
    required this.photoPath,
    required this.online,
    required this.perfect,
    required this.score,
    this.expectedPay,
    this.payCompatible,
    this.offerStatus,
  });

  final String id;
  final String name;

  /// Display texts as the API sends them: "4.9", "%100 katılım", "4.9 km".
  final String rating;
  final String attendance;
  final String distance;

  /// Server path such as `/assets/photos/merve.png`.
  final String photoPath;
  final bool online;

  /// score >= 80.
  final bool perfect;
  final int score;

  /// Monthly pay expectation, "25.000"; null when unknown.
  final String? expectedPay;
  final bool? payCompatible;

  /// The newest interview request sent to this candidate; null when none.
  final CandidateOfferStatus? offerStatus;

  /// A request is still waiting for an answer, so another one would be
  /// refused (409); the candidate cannot be selected until it is answered.
  bool get awaitingAnswer => offerStatus == CandidateOfferStatus.pending;
}
