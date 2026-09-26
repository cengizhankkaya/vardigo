import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../features/candidates/data/api_candidates_repository.dart';
import '../features/candidates/domain/candidate.dart';
import '../features/offers/data/api_offers_repository.dart';
import '../features/offers/domain/offer.dart';
import '../features/session/application/session_controller.dart';
import '../features/session/data/api_session_repository.dart';
import '../features/session/domain/session.dart';

/// Composition root: concrete implementations are chosen here only.
/// Tests override these providers with fakes.
final apiConfigProvider = Provider<ApiConfig>(
  (ref) => ApiConfig.fromEnvironment(),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    ref.watch(apiConfigProvider),
    token: () => ref.read(sessionProvider)?.token,
  ),
);

/// Downloads SVG logos; tests replace it with an in-memory client.
final svgHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => ApiSessionRepository(ref.watch(apiClientProvider)),
);

final candidatesRepositoryProvider = Provider<CandidatesRepository>(
  (ref) => ApiCandidatesRepository(ref.watch(apiClientProvider)),
);

final offersRepositoryProvider = Provider<OffersRepository>(
  (ref) => ApiOffersRepository(ref.watch(apiClientProvider)),
);
