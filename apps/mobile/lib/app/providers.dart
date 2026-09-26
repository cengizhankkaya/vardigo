import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/api/api_config.dart';
import '../core/api/api_client.dart';
import '../features/appearance/infrastructure/repositories/prefs_theme_mode_repository.dart';
import '../features/appearance/domain/entities/app_theme_mode.dart';
import '../features/candidates/infrastructure/repositories/api_candidates_repository.dart';
import '../features/candidates/domain/entities/candidate.dart';
import '../features/offers/infrastructure/repositories/api_offers_repository.dart';
import '../features/offers/domain/entities/offer.dart';
import '../features/session/presentation/controllers/session_controller.dart';
import '../features/session/infrastructure/repositories/api_session_repository.dart';
import '../features/session/domain/entities/session.dart';

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

/// Theme choice storage. `main` swaps in the device store; elsewhere (tests,
/// previews) the choice lives in memory.
final themeModeRepositoryProvider = Provider<ThemeModeRepository>(
  (ref) => InMemoryThemeModeRepository(),
);
