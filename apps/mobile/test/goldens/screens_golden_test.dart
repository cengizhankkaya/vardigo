@Tags(['golden'])
library;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/api/api_client.dart';
import 'package:vardigo/core/api/api_config.dart';
import 'package:vardigo/core/api/api_providers.dart';
import 'package:vardigo/core/l10n/l10n.dart';
import 'package:vardigo/core/theme/app_theme.dart';
import 'package:vardigo/features/candidates/application/candidates_repository_provider.dart';
import 'package:vardigo/features/candidates/infrastructure/repositories/candidates_repository_impl.dart';
import 'package:vardigo/features/candidates/presentation/pages/candidates_screen.dart';
import 'package:vardigo/features/offers/application/offers_repository_provider.dart';
import 'package:vardigo/features/offers/infrastructure/repositories/offers_repository_impl.dart';
import 'package:vardigo/features/offers/presentation/controllers/offers_controller.dart';
import 'package:vardigo/features/offers/presentation/pages/offers_screen.dart';

import '../support/fake_adapter.dart';
import 'asset_http_client.dart';

/// Both case screens at the reference size (390×844, iPhone safe area),
/// drawn from real backend responses of the freshly seeded demo, with its
/// photos, logos and Urbanist. Update after an intended change with
/// `flutter test --update-goldens test/goldens`.
void main() {
  // When the seeded offers were captured: countdowns read 21 h 32 min and
  // 18 h 0 min.
  final seededAt = DateTime.utc(2026, 9, 26, 23, 30, 0, 549);

  const origin = 'http://api.test';
  // The fresh seed, or the perfect tab after four requests were sent and
  // two of them answered.
  var candidatesFixture = 'candidates';
  final api = ApiClient(
    const ApiConfig(origin),
    token: () => 'dev-token',
    dio: Dio()
      ..httpClientAdapter = FakeAdapter(
        (options) async => switch (options.uri.path) {
          '/api/candidates' => fixture(candidatesFixture),
          '/api/offers' => fixture('offers_seed'),
          final path => throw StateError('unexpected request $path'),
        },
      ),
  );

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen,
    ThemeData theme,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844) * 2
      ..devicePixelRatio = 2
      ..padding = const FakeViewPadding(top: 47 * 2, bottom: 34 * 2)
      ..viewPadding = const FakeViewPadding(top: 47 * 2, bottom: 34 * 2);
    addTearDown(tester.view.reset);
    debugNetworkImageHttpClientProvider = AssetHttpClient.new;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiConfigProvider.overrideWithValue(const ApiConfig(origin)),
          svgHttpClientProvider.overrideWithValue(svgAssetClient()),
          candidatesRepositoryProvider.overrideWithValue(
            CandidatesRepositoryImpl(api),
          ),
          offersRepositoryProvider.overrideWithValue(OffersRepositoryImpl(api)),
          clockProvider.overrideWithValue(() => seededAt),
          countdownTickProvider.overrideWith((ref) => Stream.value(seededAt)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // ₺ comes from Roboto, loaded in flutter_test_config.dart.
          theme: theme.copyWith(
            textTheme: theme.textTheme.apply(fontFamilyFallback: ['Roboto']),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Photos decode outside the fake clock.
    await tester.runAsync(() async {
      for (final image in tester.widgetList<Image>(find.byType(Image))) {
        await precacheImage(image.image, tester.element(find.byWidget(image)));
      }
    });
    await tester.pumpAndSettle();
    debugNetworkImageHttpClientProvider = null;
  }

  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    testWidgets('candidates screen, $name', (tester) async {
      await pumpScreen(tester, const CandidatesScreen(), theme);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('candidates_$name.png'),
      );
    });

    testWidgets('candidates screen with answered requests, $name', (
      tester,
    ) async {
      candidatesFixture = 'candidates_answered';
      addTearDown(() => candidatesFixture = 'candidates');
      await pumpScreen(tester, const CandidatesScreen(), theme);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('candidates_answered_$name.png'),
      );
    });

    testWidgets('offers screen, $name', (tester) async {
      await pumpScreen(tester, const OffersScreen(), theme);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('offers_$name.png'),
      );
    });
  }
}
