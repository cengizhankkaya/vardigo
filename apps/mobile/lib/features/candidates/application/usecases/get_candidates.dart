import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/candidate_list.dart';
import '../../domain/entities/candidate_sort.dart';
import '../../domain/entities/candidate_tab.dart';
import '../../domain/repositories/i_candidates_repository.dart';
import '../candidates_repository_provider.dart';

/// Matching candidates for one tab, in one sort order.
class GetCandidates {
  const GetCandidates(this._repository);

  final ICandidatesRepository _repository;

  Future<CandidateList> call({CandidateTab? tab, CandidateSort? sort}) =>
      _repository.fetch(tab: tab, sort: sort);
}

final getCandidatesProvider = Provider<GetCandidates>(
  (ref) => GetCandidates(ref.watch(candidatesRepositoryProvider)),
);
