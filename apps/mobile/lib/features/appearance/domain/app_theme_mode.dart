/// Which theme the app uses; [system] follows the device setting.
enum AppThemeMode { system, light, dark }

/// Remembers the choice between app launches.
abstract interface class ThemeModeRepository {
  /// The saved choice, or [AppThemeMode.system] when there is none.
  AppThemeMode read();

  Future<void> write(AppThemeMode mode);
}
