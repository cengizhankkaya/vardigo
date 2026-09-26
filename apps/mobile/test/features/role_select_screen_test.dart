import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/features/candidates/presentation/candidates_screen.dart';
import 'package:vardigo/features/session/domain/session.dart';

import '../support/test_app.dart';

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
}
