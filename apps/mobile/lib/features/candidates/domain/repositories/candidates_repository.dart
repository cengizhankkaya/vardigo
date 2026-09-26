import '../entities/candidate_list.dart';
import '../entities/candidate_sort.dart';
import '../entities/candidate_tab.dart';

abstract interface class CandidatesRepository {
  Future<CandidateList> fetch({CandidateTab? tab, CandidateSort? sort});

  /// Sends the interview request to every id, or to none (API is atomic).
  /// Returns the ids of the created offers.
  Future<List<String>> sendInterviewRequests(List<String> workerIds);
}
