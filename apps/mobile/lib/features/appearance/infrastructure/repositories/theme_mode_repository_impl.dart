import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_theme_mode.dart';
import '../../domain/repositories/i_theme_mode_repository.dart';

/// Keeps the choice in the device's key-value store.
class ThemeModeRepositoryImpl implements IThemeModeRepository {
  ThemeModeRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'theme_mode';

  @override
  AppThemeMode read() {
    final saved = _prefs.getString(_key);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => AppThemeMode.light,
    );
  }

  @override
  Future<void> write(AppThemeMode mode) => _prefs.setString(_key, mode.name);
}
