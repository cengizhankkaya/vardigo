import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/providers.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/theme/app_theme.dart';
import 'package:vardigo/features/candidates/presentation/pages/candidates_screen.dart';

import '../support/fake_repositories.dart';

void main() {
  late FakeCandidatesRepository repo;

  Future<void> pumpScreen(WidgetTester tester, {ThemeData? theme}) async {
    repo = FakeCandidatesRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [candidatesRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CandidatesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the perfect tab with the first candidate selected', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('26 personel bulundu'), findsOneWidget);
    expect(find.text('%100 Eşleşme (26)'), findsOneWidget);
    expect(find.text('Benzer Personeller (16)'), findsOneWidget);
    expect(find.text('w_merve'), findsOneWidget);
    expect(find.text('w_ferhat'), findsOneWidget);
    expect(find.text('w_derya'), findsNothing);
    expect(find.text('1 kişi seçildi'), findsOneWidget);
    expect(find.text('Görüşme Talebi Gönder (1)'), findsOneWidget);
    expect(find.text('Ücret beklentisi uyuşuyor'), findsNWidgets(2));
  });

  testWidgets('keeps selections from both tabs in the count', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Benzer Personeller (16)'));
    await tester.pumpAndSettle();
    expect(find.text('w_derya'), findsOneWidget);
    expect(find.text('16 personel bulundu'), findsOneWidget);

    await tester.tap(find.text('w_derya'));
    await tester.pump();
    expect(find.text('2 kişi seçildi'), findsOneWidget);
    expect(find.text('Görüşme Talebi Gönder (2)'), findsOneWidget);
  });

  testWidgets('cycles the sort chip and asks the API', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Sırala: Önerilen'));
    await tester.pumpAndSettle();
    expect(find.text('Sırala: En Yakın'), findsOneWidget);
    expect(repo.fetches.last.$2?.name, 'near');
  });

  testWidgets('sends the selection and reports the result', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Görüşme Talebi Gönder (1)'));
    await tester.pumpAndSettle();
    expect(repo.sent.single, ['w_merve']);
    expect(find.text('1 kişiye görüşme talebi gönderildi'), findsOneWidget);
    expect(find.text('0 kişi seçildi'), findsOneWidget);

    await tester.tap(find.text('Görüşme Talebi Gönder (0)'));
    await tester.pump();
    expect(repo.sent, hasLength(1));
  });

  testWidgets('shows the backend message when sending is refused', (
    tester,
  ) async {
    await pumpScreen(tester);
    repo.sendError = const ApiException(
      code: 'OFFER_PENDING_EXISTS',
      message: 'Seçilen personel için açık teklif var: w_merve',
      statusCode: 409,
    );
    await tester.tap(find.text('Görüşme Talebi Gönder (1)'));
    await tester.pumpAndSettle();
    expect(
      find.text('Seçilen personel için açık teklif var: w_merve'),
      findsOneWidget,
    );
    expect(find.text('1 kişi seçildi'), findsOneWidget);
  });

  testWidgets('renders in the dark theme', (tester) async {
    await pumpScreen(tester, theme: AppTheme.dark());
    expect(tester.takeException(), isNull);
    expect(find.text('Görüşme Talebi Gönder (1)'), findsWidgets);
    expect(
      Theme.of(tester.element(find.byType(CandidatesScreen))).brightness,
      Brightness.dark,
    );
  });
}
