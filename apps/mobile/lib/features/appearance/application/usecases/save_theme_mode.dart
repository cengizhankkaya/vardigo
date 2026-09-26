import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/i_theme_mode_repository.dart';
import '../theme_mode_repository_provider.dart';

/// Keeps the theme choice for the next launch.
class SaveThemeMode {
  const SaveThemeMode(this._repository);

  final IThemeModeRepository _repository;

  Future<void> call(AppThemeMode mode) => _repository.write(mode);
}

final saveThemeModeProvider = Provider<SaveThemeMode>(
  (ref) => SaveThemeMode(ref.watch(themeModeRepositoryProvider)),
);
