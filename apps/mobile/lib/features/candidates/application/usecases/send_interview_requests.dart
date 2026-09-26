import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_candidates_repository.dart';
import '../candidates_repository_provider.dart';

/// Sends the demo job to every selected candidate, or to none of them.
/// Returns the ids of the created offers.
class SendInterviewRequests {
  const SendInterviewRequests(this._repository);

  final ICandidatesRepository _repository;

  Future<List<String>> call(List<String> workerIds) =>
      _repository.sendInterviewRequests(workerIds);
}

final sendInterviewRequestsProvider = Provider<SendInterviewRequests>(
  (ref) => SendInterviewRequests(ref.watch(candidatesRepositoryProvider)),
);
