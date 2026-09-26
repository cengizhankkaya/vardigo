import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vardigo/core/api/api_providers.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/theme/app_theme.dart';
import 'package:vardigo/features/offers/application/offers_repository_provider.dart';
import 'package:vardigo/features/offers/presentation/controllers/offers_controller.dart';
import 'package:vardigo/features/offers/presentation/pages/offers_screen.dart';
import 'package:vardigo/gen/colors.gen.dart';

import '../support/fake_repositories.dart';

void main() {
  late FakeOffersRepository repo;

  Future<void> pumpScreen(WidgetTester tester, {ThemeData? theme}) async {
    tester.view.physicalSize = const Size(390, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repo = FakeOffersRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          offersRepositoryProvider.overrideWithValue(repo),
          svgHttpClientProvider.overrideWithValue(
            MockClient(
              (_) async => http.Response(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 56 56">'
                '<circle cx="28" cy="28" r="28" fill="#7D52F4"/></svg>',
                200,
              ),
            ),
          ),
          clockProvider.overrideWithValue(() => testNow),
          countdownTickProvider.overrideWith((ref) => Stream.value(testNow)),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OffersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  TextSpan countdownTime(WidgetTester tester, String time) {
    TextSpan? found;
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text == time) found = span;
        return found == null;
      });
    }
    return found ?? (throw StateError('no countdown "$time"'));
  }

  testWidgets('lists pending offers with pay and a live countdown', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('Görüşme Talepleri'), findsOneWidget);
    expect(find.text('2 talep yanıt bekliyor'), findsOneWidget);
    expect(find.text('o_garson'), findsOneWidget);
    expect(find.text('₺45.000'), findsOneWidget);
    expect(find.text('₺38.000'), findsOneWidget);
    expect(find.text('İlgileniyorum'), findsNWidgets(2));

    // Under six hours left: red, like the first reference card.
    expect(
      countdownTime(tester, '5 saat 32 dakika').style?.color,
      ColorName.error,
    );
    expect(
      countdownTime(tester, '21 saat 32 dakika').style?.color,
      ColorName.strong,
    );
  });

  testWidgets('accepting moves the offer to the answered tab', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('İlgileniyorum').first);
    await tester.pumpAndSettle();
    expect(
      find.text('o_garson talebine ilgilendiğini bildirdin'),
      findsOneWidget,
    );
    expect(find.text('o_garson'), findsNothing);
    expect(find.text('1 talep yanıt bekliyor'), findsOneWidget);

    await tester.tap(find.text('Cevaplanan'));
    await tester.pumpAndSettle();
    expect(find.text('o_garson'), findsOneWidget);
    expect(find.text('İlgileniyorsun'), findsOneWidget);
    expect(find.text('İlgileniyorum'), findsNothing);
    expect(find.text('Cevaplanan talepler'), findsOneWidget);
  });

  testWidgets('shows the server reason when an answer is refused', (
    tester,
  ) async {
    await pumpScreen(tester);
    repo.respondError = const ApiException(
      code: 'OFFER_EXPIRED',
      message: 'Teklifin süresi doldu',
      statusCode: 409,
    );
    await tester.tap(find.text('İlgilenmiyorum').first);
    await tester.pumpAndSettle();
    expect(find.text('Teklifin süresi doldu'), findsOneWidget);
  });

  testWidgets('opens details with city and branch', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Detayları Gör').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Kadıköy, İstanbul · Şube: Sinanpaşa Mah.'),
      findsOneWidget,
    );
    expect(find.text('Detayları Gizle'), findsOneWidget);
  });

  testWidgets('expired and empty tabs', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.text('Süresi Dolan'));
    await tester.pumpAndSettle();
    expect(find.text('o_komi'), findsOneWidget);
    expect(find.text('Süresi doldu'), findsOneWidget);

    await tester.tap(find.text('Cevaplanan'));
    await tester.pumpAndSettle();
    expect(
      find.text('Kabul veya red ettiğin talepler burada listelenir'),
      findsOneWidget,
    );
  });

  testWidgets('renders in the dark theme', (tester) async {
    await pumpScreen(tester, theme: AppTheme.dark());
    expect(tester.takeException(), isNull);
    expect(find.text('İlgileniyorum'), findsWidgets);
    expect(
      Theme.of(tester.element(find.byType(OffersScreen))).brightness,
      Brightness.dark,
    );
  });
}
