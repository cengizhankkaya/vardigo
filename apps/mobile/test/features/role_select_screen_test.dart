import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/presentation/widgets/brand_logo.dart';
import 'package:vardigo/core/theme/theme.dart';
import 'package:vardigo/features/appearance/application/theme_mode_repository_provider.dart';
import 'package:vardigo/features/candidates/presentation/pages/candidates_screen.dart';
import 'package:vardigo/features/session/application/session_repository_provider.dart';
import 'package:vardigo/features/session/domain/entities/role.dart';
import 'package:vardigo/features/session/domain/entities/session.dart';
import 'package:vardigo/features/session/domain/repositories/i_session_repository.dart';
import 'package:vardigo/features/session/presentation/pages/role_select_screen.dart';
import 'package:vardigo/features/session/presentation/widgets/role_card.dart';

import '../support/fake_repositories.dart';
import '../support/test_app.dart';

class _PendingSessionRepository implements ISessionRepository {
  final pending = Completer<Session>();
  final logins = <Role>[];

  @override
  Future<Session> login(Role role) {
    logins.add(role);
    return pending.future;
  }
}

Future<void> _pumpLogin(
  WidgetTester tester, {
  required ISessionRepository sessions,
  Size size = const Size(390, 844),
  double textScale = 1,
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(sessions),
        themeModeRepositoryProvider.overrideWithValue(
          FakeThemeModeRepository(),
        ),
      ],
      child: MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const RoleSelectScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('"Tekrar dene" logs in again with the same account', (
    tester,
  ) async {
    final app = TestApp(loginFailures: 1);
    await app.pump(tester);

    await tester.tap(find.text('İşveren'));
    await tester.pumpAndSettle();
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byType(CandidatesScreen), findsNothing);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(app.sessions.logins, [Role.employer, Role.employer]);
    expect(find.byType(CandidatesScreen), findsOneWidget);
  });

  testWidgets('branding is decorative and both roles disable during login', (
    tester,
  ) async {
    final sessions = _PendingSessionRepository();
    await _pumpLogin(tester, sessions: sessions);

    final watermark = find.byKey(const ValueKey('login-brand-watermark'));
    expect(tester.widget<BrandLogo>(watermark).decorative, isTrue);
    expect(
      tester
          .widgetList<IgnorePointer>(
            find.ancestor(of: watermark, matching: find.byType(IgnorePointer)),
          )
          .any((widget) => widget.ignoring),
      isTrue,
    );

    await tester.tap(find.text('İşveren'));
    await tester.pump();
    expect(sessions.logins, [Role.employer]);
    for (final card in tester.widgetList<RoleCard>(find.byType(RoleCard))) {
      expect(card.onTap, isNull);
    }
    await tester.tap(find.text('İş arayan'));
    await tester.pump();
    expect(sessions.logins, [Role.employer]);

    sessions.pending.completeError(
      const ApiException(code: ApiException.network, message: ''),
    );
    await tester.pumpAndSettle();
    for (final card in tester.widgetList<RoleCard>(find.byType(RoleCard))) {
      expect(card.onTap, isNotNull);
    }
    expect(find.text('Tekrar dene'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets(
      'login scrolls at 2x text on a short ${dark ? 'dark' : 'light'} screen',
      (tester) async {
        await _pumpLogin(
          tester,
          sessions: FakeSessionRepository(),
          size: const Size(320, 480),
          textScale: 2,
          dark: dark,
        );
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(find.text('İşveren'));
        await tester.pumpAndSettle();
        expect(find.text('İşveren').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.text('İş arayan'));
        await tester.pumpAndSettle();
        expect(find.text('İş arayan').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
