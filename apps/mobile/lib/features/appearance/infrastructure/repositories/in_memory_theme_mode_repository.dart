import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/theme_mode_repository.dart';

/// Keeps the choice only while the app runs; the default outside `main`.
class InMemoryThemeModeRepository implements ThemeModeRepository {
  AppThemeMode _mode = AppThemeMode.light;

  @override
  AppThemeMode read() => _mode;

  @override
  Future<void> write(AppThemeMode mode) async => _mode = mode;
}
