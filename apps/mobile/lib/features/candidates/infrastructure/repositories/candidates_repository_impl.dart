import '../../../../core/api/api_client.dart';
import '../../../../core/api/json_reader.dart';
import '../../domain/entities/candidate.dart';
import '../../domain/entities/candidate_list.dart';
import '../../domain/entities/candidate_offer_status.dart';
import '../../domain/entities/candidate_sort.dart';
import '../../domain/entities/candidate_tab.dart';
import '../../domain/repositories/i_candidates_repository.dart';

class CandidatesRepositoryImpl implements ICandidatesRepository {
  CandidatesRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<CandidateList> fetch({CandidateTab? tab, CandidateSort? sort}) async {
    final data = JsonReader.of(
      await _api.get(
        '/candidates',
        query: {'tab': ?tab?.name, 'sort': ?sort?.name},
      ),
    );
    return CandidateList(
      totalPerfect: data.read<int>('totalPerfect'),
      totalSimilar: data.read<int>('totalSimilar'),
      selectedHint: data.read<int>('selectedHint'),
      candidates: data.readList('candidates', candidateFromJson),
    );
  }

  @override
  Future<List<String>> sendInterviewRequests(List<String> workerIds) async {
    final data = JsonReader.of(
      await _api.post('/offers', body: {'workerIds': workerIds}),
    );
    return data.readList('created', (offer) => offer.read<String>('id'));
  }
}

Candidate candidateFromJson(JsonReader json) => Candidate(
  id: json.read<String>('id'),
  name: json.read<String>('name'),
  rating: json.read<String>('rating'),
  attendance: json.read<String>('attend'),
  distance: json.read<String>('km'),
  photoPath: json.read<String>('photo'),
  online: json.read<bool>('online'),
  perfect: json.read<bool>('perfect'),
  score: json.read<int>('score'),
  expectedPay: json.readOptional<String>('expectedPay'),
  payCompatible: json.readOptional<bool>('payCompatible'),
  offerStatus: json.readOptionalEnum(
    'offerStatus',
    CandidateOfferStatus.values,
  ),
);
