enum CandidateTab { perfect, similar }

enum CandidateSort { recommended, near, rating }

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

class CandidateList {
  const CandidateList({
    required this.totalPerfect,
    required this.totalSimilar,
    required this.selectedHint,
    required this.candidates,
  });

  /// Fixed header numbers from the reference design (26 / 16).
  final int totalPerfect;
  final int totalSimilar;
  final int selectedHint;
  final List<Candidate> candidates;
}

abstract interface class CandidatesRepository {
  Future<CandidateList> fetch({CandidateTab? tab, CandidateSort? sort});

  /// Sends the interview request to every id, or to none (API is atomic).
  /// Returns the ids of the created offers.
  Future<List<String>> sendInterviewRequests(List<String> workerIds);
}
