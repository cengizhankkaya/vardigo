import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/app_theme_mode.dart';

/// The active theme choice. Starts from the saved one; each change is saved.
final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(
      ThemeModeController.new,
    );

class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => ref.read(themeModeRepositoryProvider).read();

  Future<void> setMode(AppThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await ref.read(themeModeRepositoryProvider).write(mode);
  }
}
