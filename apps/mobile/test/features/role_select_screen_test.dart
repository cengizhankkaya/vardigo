import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/providers.dart';
import 'package:vardigo/core/network/api_exception.dart';
import 'package:vardigo/features/candidates/presentation/candidates_screen.dart';
import 'package:vardigo/features/session/domain/session.dart';
import 'package:vardigo/features/session/presentation/role_select_screen.dart';
import 'package:vardigo/l10n/l10n.dart';
import 'package:vardigo/shared/design_system/theme/app_theme.dart';

import '../support/fake_repositories.dart';

/// Fails the first login with a connection problem, then succeeds.
class _FlakySessionRepository implements SessionRepository {
  int failures = 1;
  final logins = <Role>[];

  @override
  Future<Session> login(Role role) async {
    logins.add(role);
    if (failures > 0) {
      failures--;
      throw const ApiException(code: ApiException.network, message: '');
    }
    return Session(token: 'dev-${role.name}', role: role);
  }
}

void main() {
  testWidgets('"Tekrar dene" logs in again with the same account', (
    tester,
  ) async {
    final sessions = _FlakySessionRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionRepositoryProvider.overrideWithValue(sessions),
          candidatesRepositoryProvider.overrideWithValue(
            FakeCandidatesRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const RoleSelectScreen(),
        ),
      ),
    );

    await tester.tap(find.text('İşveren'));
    await tester.pumpAndSettle();
    expect(find.text('Tekrar dene'), findsOneWidget);
    expect(find.byType(CandidatesScreen), findsNothing);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();
    expect(sessions.logins, [Role.employer, Role.employer]);
    expect(find.byType(CandidatesScreen), findsOneWidget);
  });
}
