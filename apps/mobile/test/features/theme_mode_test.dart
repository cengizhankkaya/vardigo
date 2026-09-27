import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vardigo/app/app.dart';
import 'package:vardigo/features/appearance/application/theme_mode_repository_provider.dart';
import 'package:vardigo/features/appearance/domain/entities/app_theme_mode.dart';
import 'package:vardigo/features/appearance/infrastructure/repositories/theme_mode_repository_impl.dart';
import 'package:vardigo/features/appearance/presentation/controllers/theme_mode_controller.dart';
import 'package:vardigo/features/appearance/presentation/widgets/theme_mode_switch.dart';
import 'package:vardigo/features/session/presentation/pages/role_select_screen.dart';
import 'package:vardigo/gen/colors.gen.dart';

import '../support/fake_repositories.dart';

void main() {
  group('ThemeModeRepositoryImpl', () {
    test('starts on light and keeps what is written', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ThemeModeRepositoryImpl(prefs);
      expect(repo.read(), AppThemeMode.light);

      await repo.write(AppThemeMode.dark);
      expect(ThemeModeRepositoryImpl(prefs).read(), AppThemeMode.dark);
    });

    test('an unknown saved value falls back to light', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
      final repo = ThemeModeRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      expect(repo.read(), AppThemeMode.light);
    });
  });

  test('controller starts from the saved choice and saves changes', () async {
    final repo = FakeThemeModeRepository();
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

  testWidgets('the switch flips the app between light and dark', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeRepositoryProvider.overrideWithValue(
            FakeThemeModeRepository(),
          ),
        ],
        child: const VardigoApp(),
      ),
    );
    await tester.pumpAndSettle();

    ThemeData theme() =>
        Theme.of(tester.element(find.byType(RoleSelectScreen)));
    expect(theme().brightness, Brightness.light);

    await tester.tap(find.byType(ThemeModeSwitch));
    await tester.pumpAndSettle();
    expect(theme().brightness, Brightness.dark);
    expect(theme().scaffoldBackgroundColor, ColorName.strong);

    await tester.tap(find.byType(ThemeModeSwitch));
    await tester.pumpAndSettle();
    expect(theme().brightness, Brightness.light);
  });
}
