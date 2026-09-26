import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vardigo/app/app.dart';
import 'package:vardigo/app/providers.dart';
import 'package:vardigo/app/router/app_router.dart';
import 'package:vardigo/features/offers/presentation/controllers/offers_controller.dart';

import 'fake_repositories.dart';

/// The whole app with its real router and in-memory repositories.
class TestApp {
  TestApp({int loginFailures = 0})
    : sessions = FakeSessionRepository(failures: loginFailures);

  final FakeSessionRepository sessions;
  final candidates = FakeCandidatesRepository();
  final offers = FakeOffersRepository();
  late final ProviderContainer container;

  GoRouter get router => container.read(appRouterProvider);

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(600, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(
      overrides: [
        sessionRepositoryProvider.overrideWithValue(sessions),
        candidatesRepositoryProvider.overrideWithValue(candidates),
        offersRepositoryProvider.overrideWithValue(offers),
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
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const VardigoApp(referenceFrame: false),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Opens [location] as a deep link would.
  Future<void> open(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pumpAndSettle();
  }
}
