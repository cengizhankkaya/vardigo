import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/usecases/get_theme_mode.dart';
import '../../application/usecases/save_theme_mode.dart';
import '../../domain/entities/app_theme_mode.dart';

/// The active theme choice. Starts from the saved one; each change is saved.
final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(
      ThemeModeController.new,
    );

class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => ref.read(getThemeModeProvider)();

  Future<void> setMode(AppThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await ref.read(saveThemeModeProvider)(mode);
  }
}
