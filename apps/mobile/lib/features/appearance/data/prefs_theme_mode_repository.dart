import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_theme_mode.dart';

/// Keeps the choice in the device's key-value store.
class PrefsThemeModeRepository implements ThemeModeRepository {
  PrefsThemeModeRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'theme_mode';

  @override
  AppThemeMode read() {
    final saved = _prefs.getString(_key);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => AppThemeMode.system,
    );
  }

  @override
  Future<void> write(AppThemeMode mode) => _prefs.setString(_key, mode.name);
}

/// Keeps the choice only while the app runs; the default outside `main`.
class InMemoryThemeModeRepository implements ThemeModeRepository {
  AppThemeMode _mode = AppThemeMode.system;

  @override
  AppThemeMode read() => _mode;

  @override
  Future<void> write(AppThemeMode mode) async => _mode = mode;
}
