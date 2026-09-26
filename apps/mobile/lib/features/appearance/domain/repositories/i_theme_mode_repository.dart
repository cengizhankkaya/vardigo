import '../entities/app_theme_mode.dart';

/// Remembers the choice between app launches.
abstract interface class IThemeModeRepository {
  /// The saved choice, or [AppThemeMode.light] when there is none: the case
  /// screens must match the light reference on any device.
  AppThemeMode read();

  Future<void> write(AppThemeMode mode);
}
