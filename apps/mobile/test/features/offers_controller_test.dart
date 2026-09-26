import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/features/offers/presentation/controllers/offers_controller.dart';

import '../support/fake_repositories.dart';

import 'package:vardigo/features/offers/domain/entities/offer_status.dart';
import 'package:vardigo/features/offers/domain/entities/offer_tab.dart';
import 'package:vardigo/features/offers/domain/entities/offer_sort.dart';
import 'package:vardigo/features/offers/domain/entities/offer_list.dart';
import 'package:vardigo/features/offers/presentation/controllers/offer_query.dart';
import 'package:vardigo/features/offers/presentation/controllers/offers_state.dart';
import 'package:vardigo/features/offers/presentation/controllers/respond_result.dart';
import 'package:vardigo/features/offers/application/offers_repository_provider.dart';

void main() {
  late FakeOffersRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeOffersRepository();
    container = ProviderContainer(
      overrides: [
        offersRepositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => testNow),
      ],
    );
    addTearDown(container.dispose);
    container.listen(offersControllerProvider(defaultOfferQuery), (_, _) {});
  });

  OffersController controller() =>
      container.read(offersControllerProvider(defaultOfferQuery).notifier);
  OffersState state() =>
      container.read(offersControllerProvider(defaultOfferQuery));
  Future<OfferList> load() =>
      container.read(offerListProvider(state().query).future);

  test('opens on pending, recommended', () async {
    expect(state().tab, OfferTab.pending);
    expect((await load()).offers.map((o) => o.id), ['o_garson', 'o_barista']);
  });

  test('cycles sort and asks the API', () async {
    controller().cycleSort();
    expect(state().sort, OfferSort.expiring);
    await load();
    expect(repo.fetches.last, (OfferTab.pending, OfferSort.expiring));
    controller()
      ..cycleSort()
      ..cycleSort();
    expect(state().sort, OfferSort.recommended);
  });

  test('accepting moves the offer to the answered tab', () async {
    await load();
    final garson = repo.offers['o_garson']!;
    final result = await controller().respond(garson, accept: true);
    expect(
      result,
      isA<Responded>().having(
        (r) => r.offer.status,
        'status',
        OfferStatus.accepted,
      ),
    );
    expect(state().busy, isEmpty);
    expect((await load()).offers.map((o) => o.id), ['o_barista']);

    controller().selectTab(OfferTab.answered);
    expect((await load()).offers.single.id, 'o_garson');
  });

  test('a refused answer reports the backend error and reloads', () async {
    final fetchesBefore = repo.fetches.length;
    repo.respondError = const ApiException(
      code: 'OFFER_EXPIRED',
      message: 'Teklifin süresi doldu',
      statusCode: 409,
    );
    final result = await controller().respond(
      repo.offers['o_garson']!,
      accept: false,
    );
    expect(
      result,
      isA<RespondFailed>().having((r) => r.error.code, 'code', 'OFFER_EXPIRED'),
    );
    await load();
    expect(repo.fetches.length, greaterThan(fetchesBefore));
  });

  test('toggles details per offer', () {
    controller().toggleDetails('o_garson');
    expect(state().expanded, {'o_garson'});
    controller().toggleDetails('o_garson');
    expect(state().expanded, isEmpty);
  });

  group('Offer time rules', () {
    test('remaining time never goes negative', () {
      final late = offer('x', left: const Duration(minutes: -5));
      expect(late.remainingAt(testNow), Duration.zero);
    });

    test('pending offers under six hours are urgent', () {
      expect(
        offer(
          'a',
          left: const Duration(hours: 5, minutes: 59),
        ).isUrgentAt(testNow),
        isTrue,
      );
      expect(
        offer('b', left: const Duration(hours: 6)).isUrgentAt(testNow),
        isFalse,
      );
      expect(
        offer(
          'c',
          status: OfferStatus.accepted,
          left: const Duration(hours: 1),
        ).isUrgentAt(testNow),
        isFalse,
      );
    });
  });

  test(
    'an answer after leaving the screen still reloads the next visit',
    () async {
      final local = ProviderContainer(
        overrides: [offersRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(local.dispose);
      final sub = local.listen(
        offersControllerProvider(defaultOfferQuery),
        (_, _) {},
      );
      repo.pendingRespond = Completer();
      final result = local
          .read(offersControllerProvider(defaultOfferQuery).notifier)
          .respond(repo.offers['o_garson']!, accept: true);

      // Leave, then open the screen again while the answer is on its way.
      sub.close();
      await Future<void>.delayed(Duration.zero);
      local.listen(offersControllerProvider(defaultOfferQuery), (_, _) {});
      local.listen(offerListProvider(defaultOfferQuery), (_, _) {});
      Future<List<String>> ids() async => [
        for (final o in (await local.read(
          offerListProvider(defaultOfferQuery).future,
        )).offers)
          o.id,
      ];
      expect(await ids(), ['o_garson', 'o_barista']);

      repo.pendingRespond!.complete();
      expect(await result, isA<Responded>());
      expect(await ids(), ['o_barista']);
    },
  );
}
