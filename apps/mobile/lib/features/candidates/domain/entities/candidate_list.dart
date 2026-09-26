import 'candidate.dart';

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
