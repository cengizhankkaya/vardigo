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
}
