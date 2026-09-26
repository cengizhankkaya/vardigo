import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/i_theme_mode_repository.dart';
import '../theme_mode_repository_provider.dart';

/// The saved theme choice; light when there is none.
class GetThemeMode {
  const GetThemeMode(this._repository);

  final IThemeModeRepository _repository;

  AppThemeMode call() => _repository.read();
}

final getThemeModeProvider = Provider<GetThemeMode>(
  (ref) => GetThemeMode(ref.watch(themeModeRepositoryProvider)),
);
