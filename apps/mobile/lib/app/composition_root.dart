import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/api/api_providers.dart';
import '../features/appearance/application/theme_mode_repository_provider.dart';
import '../features/appearance/infrastructure/repositories/theme_mode_repository_impl.dart';
import '../features/candidates/application/candidates_repository_provider.dart';
import '../features/candidates/infrastructure/repositories/candidates_repository_impl.dart';
import '../features/offers/application/offers_repository_provider.dart';
import '../features/offers/infrastructure/repositories/offers_repository_impl.dart';
import '../features/session/application/session_repository_provider.dart';
import '../features/session/infrastructure/repositories/session_repository_impl.dart';
import '../features/session/presentation/controllers/session_controller.dart';

/// Composition root: the only place that names infrastructure adapters.
/// Features see ports (`I…Repository`) through their application layer.

/// Backend client; sends the demo session's token with every call.
final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    ref.watch(apiConfigProvider),
    token: () => ref.read(sessionProvider)?.token,
  ),
);

/// Binds every backend port to its HTTP adapter.
final List<Override> apiAdapters = [
  sessionRepositoryProvider.overrideWith(
    (ref) => SessionRepositoryImpl(ref.watch(apiClientProvider)),
  ),
  candidatesRepositoryProvider.overrideWith(
    (ref) => CandidatesRepositoryImpl(ref.watch(apiClientProvider)),
  ),
  offersRepositoryProvider.overrideWith(
    (ref) => OffersRepositoryImpl(ref.watch(apiClientProvider)),
  ),
];

/// All adapters of the running app.
List<Override> appAdapters(SharedPreferences prefs) => [
  ...apiAdapters,
  themeModeRepositoryProvider.overrideWithValue(ThemeModeRepositoryImpl(prefs)),
];
