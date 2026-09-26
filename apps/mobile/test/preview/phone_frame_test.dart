import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';
import 'package:vardigo/app/reference_frame/phone_frame.dart';
import 'package:vardigo/app/reference_frame/reference_frame_view.dart';
import 'package:vardigo/core/theme/app_theme.dart';
import 'package:vardigo/features/appearance/application/theme_mode_repository_provider.dart';

import '../support/fake_repositories.dart';

void main() {
  testWidgets('frame is 390×844 and gives the screen the reference insets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late MediaQueryData inner;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Center(
          child: PhoneFrame(
            child: Builder(
              builder: (context) {
                inner = MediaQuery.of(context);
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(PhoneFrame)), const Size(390, 844));
    expect(inner.size, const Size(368, 822));
    expect(inner.padding, const EdgeInsets.only(top: 54, bottom: 30));
    expect(find.text('9:41'), findsOneWidget);
  });

  testWidgets('status time has no fallback underline outside Material', (
    tester,
  ) async {
    // In the app the frame sits in MaterialApp.builder: themed, but above
    // the Navigator and outside any Material.
    await tester.pumpWidget(
      Theme(
        data: AppTheme.light(),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: PhoneFrame(child: SizedBox.expand())),
        ),
      ),
    );
    final style = DefaultTextStyle.of(tester.element(find.text('9:41'))).style;
    expect(style.decoration, isNot(TextDecoration.underline));
    expect(style.fontSize, 17);
  });

  testWidgets('frame scales down on a screen smaller than the phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const ReferenceFrameView(child: SizedBox.expand()),
      ),
    );

    final rect = tester.getRect(find.byType(PhoneFrame));
    expect(rect.height, lessThanOrEqualTo(568));
    expect(rect.width / rect.height, closeTo(390 / 844, 0.001));
  });

  testWidgets('app runs inside the frame when asked', (tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          themeModeRepositoryProvider.overrideWithValue(
            FakeThemeModeRepository(),
          ),
        ],
        child: const VardigoApp(referenceFrame: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PhoneFrame), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PhoneFrame),
        matching: find.text('Demo hesabı seç'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('app uses the device edges by default', (tester) async {
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
    expect(find.byType(PhoneFrame), findsNothing);
  });
}
