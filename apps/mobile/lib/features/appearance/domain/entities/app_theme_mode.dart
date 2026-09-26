/// Which theme the app uses; [system] follows the device setting.
enum AppThemeMode { system, light, dark }

/// Remembers the choice between app launches.
abstract interface class ThemeModeRepository {
  /// The saved choice, or [AppThemeMode.light] when there is none: the case
  /// screens must match the light reference on any device.
  AppThemeMode read();

  Future<void> write(AppThemeMode mode);
}
