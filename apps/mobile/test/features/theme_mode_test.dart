import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vardigo/app/app.dart';
import 'package:vardigo/app/providers.dart';
import 'package:vardigo/features/appearance/application/theme_mode_controller.dart';
import 'package:vardigo/features/appearance/data/prefs_theme_mode_repository.dart';
import 'package:vardigo/features/appearance/domain/app_theme_mode.dart';
import 'package:vardigo/features/session/presentation/role_select_screen.dart';
import 'package:vardigo/gen/colors.gen.dart';

void main() {
  group('PrefsThemeModeRepository', () {
    test('starts on light and keeps what is written', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PrefsThemeModeRepository(prefs);
      expect(repo.read(), AppThemeMode.light);

      await repo.write(AppThemeMode.dark);
      expect(PrefsThemeModeRepository(prefs).read(), AppThemeMode.dark);
    });

    test('an unknown saved value falls back to light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
      final repo = PrefsThemeModeRepository(
        await SharedPreferences.getInstance(),
      );
      expect(repo.read(), AppThemeMode.light);
    });
  });

  test('controller starts from the saved choice and saves changes', () async {
    final repo = InMemoryThemeModeRepository();
    await repo.write(AppThemeMode.light);
    final container = ProviderContainer(
      overrides: [themeModeRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeControllerProvider), AppThemeMode.light);
    await container
        .read(themeModeControllerProvider.notifier)
        .setMode(AppThemeMode.dark);
    expect(container.read(themeModeControllerProvider), AppThemeMode.dark);
    expect(repo.read(), AppThemeMode.dark);
  });

  testWidgets('picking "Koyu" switches the app to the dark theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: VardigoApp()));
    await tester.pumpAndSettle();

    ThemeData theme() =>
        Theme.of(tester.element(find.byType(RoleSelectScreen)));
    await tester.tap(find.text('Açık'));
    await tester.pumpAndSettle();
    expect(theme().brightness, Brightness.light);

    await tester.tap(find.text('Koyu'));
    await tester.pumpAndSettle();
    expect(theme().brightness, Brightness.dark);
    expect(theme().scaffoldBackgroundColor, ColorName.strong);
  });
}
