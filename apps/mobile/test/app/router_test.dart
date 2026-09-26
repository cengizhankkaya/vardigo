import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/router/app_router.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate.dart';
import 'package:vardigo/features/candidates/presentation/pages/candidates_screen.dart';
import 'package:vardigo/features/offers/presentation/pages/offers_screen.dart';
import 'package:vardigo/features/session/presentation/controllers/session_controller.dart';
import 'package:vardigo/features/session/domain/entities/session.dart';
import 'package:vardigo/features/session/presentation/pages/role_select_screen.dart';

import '../support/test_app.dart';

void main() {
  group('guardRedirect', () {
    const employer = Session(token: 'dev-employer', role: Role.employer);
    const worker = Session(token: 'dev-worker', role: Role.worker);
    String? guard(String location, Session? session, {bool gallery = true}) =>
        guardRedirect(Uri.parse(location), session, allowGallery: gallery);

    test('opens a screen for the account it belongs to', () {
      expect(guard('/candidates', employer), isNull);
      expect(guard('/offers?tab=answered', worker), isNull);
      expect(guard('/', null), isNull);
    });

    test('sends other visitors to role selection, keeping the address', () {
      expect(
        guard('/candidates?tab=similar', null),
        '/?from=%2Fcandidates%3Ftab%3Dsimilar',
      );
      expect(guard('/offers', employer), '/?from=%2Foffers');
    });

    test('closes the gallery outside debug builds', () {
      expect(guard('/gallery', null), isNull);
      expect(guard('/gallery', null, gallery: false), '/');
    });

    test('each role has a home screen', () {
      expect(homeLocationFor(Role.employer), '/candidates');
      expect(homeLocationFor(Role.worker), '/offers');
    });
  });

  testWidgets('a deep link waits for the right account, then opens', (
    tester,
  ) async {
    final app = TestApp();
    await app.pump(tester);

    await app.open(tester, '/candidates?tab=similar&sort=near');
    expect(find.byType(RoleSelectScreen), findsOneWidget);
    expect(find.byType(CandidatesScreen), findsNothing);

    await tester.tap(find.text('İşveren'));
    await tester.pumpAndSettle();
    expect(find.byType(CandidatesScreen), findsOneWidget);
    // The similar tab, sorted by distance.
    expect(find.text('w_derya'), findsOneWidget);
    expect(find.text('w_merve'), findsNothing);
    expect(find.text('Sırala: En Yakın'), findsOneWidget);
    expect(
      app.candidates.fetches,
      contains((CandidateTab.similar, CandidateSort.near)),
    );
  });

  testWidgets('choosing the other account goes to its own screen', (
    tester,
  ) async {
    final app = TestApp();
    await app.pump(tester);
    await app.open(tester, '/candidates');

    await tester.tap(find.text('İş arayan'));
    await tester.pumpAndSettle();
    expect(find.byType(OffersScreen), findsOneWidget);
  });

  testWidgets('back returns to role selection and ends the session', (
    tester,
  ) async {
    final app = TestApp();
    await app.pump(tester);
    await tester.tap(find.text('İş arayan'));
    await tester.pumpAndSettle();
    expect(find.byType(OffersScreen), findsOneWidget);
    expect(app.container.read(sessionProvider)?.role, Role.worker);

    await tester.tap(find.bySemanticsLabel('Geri'));
    await tester.pumpAndSettle();
    expect(find.byType(RoleSelectScreen), findsOneWidget);
    expect(app.container.read(sessionProvider), isNull);
  });

  testWidgets('an unknown address shows the error page', (tester) async {
    final app = TestApp();
    await app.pump(tester);
    await app.open(tester, '/nowhere');
    expect(find.text('Sayfa bulunamadı'), findsOneWidget);
    expect(find.text('/nowhere adresinde bir ekran yok.'), findsOneWidget);

    await tester.tap(find.text('Rol seçimine dön'));
    await tester.pumpAndSettle();
    expect(find.byType(RoleSelectScreen), findsOneWidget);
  });

  testWidgets('a link while logged in keeps the session', (tester) async {
    final app = TestApp();
    await app.pump(tester);
    await tester.tap(find.text('İşveren'));
    await tester.pumpAndSettle();
    expect(find.text('w_merve'), findsOneWidget);

    await app.open(tester, '/candidates?tab=similar');
    expect(find.byType(CandidatesScreen), findsOneWidget);
    expect(find.text('w_derya'), findsOneWidget);
    expect(app.container.read(sessionProvider)?.role, Role.employer);
  });

  testWidgets('a link for the other account ends the session', (tester) async {
    final app = TestApp();
    await app.pump(tester);
    await tester.tap(find.text('İşveren'));
    await tester.pumpAndSettle();

    await app.open(tester, '/offers');
    expect(find.byType(RoleSelectScreen), findsOneWidget);
    expect(app.container.read(sessionProvider), isNull);

    await tester.tap(find.text('İş arayan'));
    await tester.pumpAndSettle();
    expect(find.byType(OffersScreen), findsOneWidget);
  });

  testWidgets('a link from the operating system reaches the router', (
    tester,
  ) async {
    final app = TestApp();
    await app.pump(tester);
    await tester.tap(find.text('İşveren'));
    await tester.pumpAndSettle();

    // What the engine does after iOS/Android open vardigo://app/...
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.navigation.name,
      SystemChannels.navigation.codec.encodeMethodCall(
        const MethodCall('pushRouteInformation', {
          'location': '/candidates?tab=similar',
          'state': null,
        }),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();
    expect(find.text('w_derya'), findsOneWidget);
    expect(find.text('w_merve'), findsNothing);
  });
}
