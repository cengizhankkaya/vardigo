import 'dart:async';

import 'package:vardigo/features/candidates/domain/candidate.dart';

Candidate candidate(String id, {bool perfect = true}) => Candidate(
  id: id,
  name: id,
  rating: '4.9',
  attendance: '%100 katılım',
  distance: '4.9 km',
  photoPath: '/assets/photos/$id.png',
  online: true,
  perfect: perfect,
  score: perfect ? 90 : 70,
  expectedPay: '25.000',
  payCompatible: perfect,
);

/// In-memory candidates: w_merve and w_ferhat are perfect, w_derya and
/// w_ayse similar. [sendResult] decides how sending ends.
class FakeCandidatesRepository implements CandidatesRepository {
  final fetches = <(CandidateTab?, CandidateSort?)>[];
  final sent = <List<String>>[];
  Completer<List<String>>? pendingSend;
  Object? sendError;

  static final all = [
    candidate('w_merve'),
    candidate('w_ferhat'),
    candidate('w_derya', perfect: false),
    candidate('w_ayse', perfect: false),
  ];

  @override
  Future<CandidateList> fetch({CandidateTab? tab, CandidateSort? sort}) async {
    fetches.add((tab, sort));
    return CandidateList(
      totalPerfect: 26,
      totalSimilar: 16,
      selectedHint: 1,
      candidates: [
        for (final c in all)
          if (tab == null || c.perfect == (tab == CandidateTab.perfect)) c,
      ],
    );
  }

  @override
  Future<List<String>> sendInterviewRequests(List<String> workerIds) async {
    sent.add(workerIds);
    final error = sendError;
    if (error != null) throw error;
    final pending = pendingSend;
    if (pending != null) return pending.future;
    return [for (final id in workerIds) 'o_$id'];
  }
}
