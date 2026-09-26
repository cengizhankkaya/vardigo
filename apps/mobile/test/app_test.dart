import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/app.dart';
import 'package:vardigo/features/appearance/application/theme_mode_repository_provider.dart';

import 'support/fake_repositories.dart';

void main() {
  testWidgets('app opens the demo account picker', (tester) async {
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
    expect(find.text('Demo hesabı seç'), findsOneWidget);
    expect(find.text('İşveren'), findsOneWidget);
    expect(find.text('İş arayan'), findsOneWidget);
  });
}
