import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/api/api_config.dart';
import 'package:vardigo/core/api/api_client.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/features/candidates/infrastructure/repositories/api_candidates_repository.dart';
import 'package:vardigo/features/offers/infrastructure/repositories/api_offers_repository.dart';
import 'package:vardigo/features/session/infrastructure/repositories/api_session_repository.dart';

import '../support/fake_adapter.dart';

import 'package:vardigo/features/candidates/domain/entities/candidate_tab.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate_sort.dart';
import 'package:vardigo/features/offers/domain/entities/offer_status.dart';
import 'package:vardigo/features/offers/domain/entities/offer_sort.dart';
import 'package:vardigo/features/session/domain/entities/role.dart';

/// Parses responses captured from the real backend, so the Dart models and
/// the API contract cannot drift apart silently.
void main() {
  late FakeAdapter adapter;

  ApiClient api(Map<String, ResponseBody Function()> routes) {
    adapter = FakeAdapter((options) async {
      final key = '${options.method} ${options.uri.path}';
      final route = routes[key];
      if (route == null) fail('unexpected request $key');
      return route();
    });
    return ApiClient(
      const ApiConfig('http://api.test'),
      token: () => 'dev-worker',
      dio: Dio()..httpClientAdapter = adapter,
    );
  }

  test('login returns the demo session', () async {
    final repo = ApiSessionRepository(
      api({'POST /api/auth/login': () => fixture('login_worker')}),
    );
    final session = await repo.login(Role.worker);
    expect(session.token, 'dev-worker');
    expect(session.role, Role.worker);
    expect(adapter.requests.single.data, {'role': 'worker'});
  });

  test('candidates map every field', () async {
    final repo = ApiCandidatesRepository(
      api({'GET /api/candidates': () => fixture('candidates')}),
    );
    final list = await repo.fetch(
      tab: CandidateTab.perfect,
      sort: CandidateSort.near,
    );
    expect(adapter.requests.single.uri.query, 'tab=perfect&sort=near');
    expect(list.totalPerfect, 26);
    expect(list.candidates, hasLength(4));

    final merve = list.candidates.first;
    expect(merve.name, 'Merve Y.');
    expect(merve.attendance, '%100 katılım');
    expect(merve.photoPath, '/assets/photos/merve.png');
    expect(merve.perfect, isTrue);
    expect(merve.expectedPay, '25.000');
    expect(merve.payCompatible, isTrue);
  });

  test('omits empty query parameters', () async {
    final repo = ApiCandidatesRepository(
      api({'GET /api/candidates': () => fixture('candidates')}),
    );
    await repo.fetch();
    expect(adapter.requests.single.uri.query, isEmpty);
  });

  test('sending requests returns the created offer ids', () async {
    final repo = ApiCandidatesRepository(
      api({'POST /api/offers': () => fixture('offers_created', status: 201)}),
    );
    final ids = await repo.sendInterviewRequests(['w_merve', 'w_derya']);
    expect(ids, hasLength(2));
    expect(ids, everyElement(startsWith('o_')));
    expect(adapter.requests.single.data, {
      'workerIds': ['w_merve', 'w_derya'],
    });
  });

  test('offer list, detail and answer map every field', () async {
    final repo = ApiOffersRepository(
      api({
        'GET /api/offers': () => fixture('offers_pending'),
        'GET /api/offers/o_barista': () => fixture('offer_detail'),
        'POST /api/offers/o_garson/accept': () => fixture('offer_accepted'),
      }),
    );

    final list = await repo.fetch(sort: OfferSort.pay);
    expect(adapter.requests.last.uri.query, 'status=pending&sort=pay');
    expect(list.pendingCount, 5);
    expect(list.pendingCountLabel, 12);
    final garson = list.offers.firstWhere((o) => o.id == 'o_garson');
    expect(garson.pay, '45.000');
    expect(garson.when, '16 Ağu · 12:00 - 16:00');
    expect(garson.status, OfferStatus.pending);
    expect(garson.remain, contains('saat'));
    expect(garson.expiresAt.isUtc, isTrue);

    final detail = await repo.detail('o_barista');
    expect(detail.city, 'İstanbul');
    expect(detail.note, 'Şube: Sinanpaşa Mah.');

    final accepted = await repo.accept('o_garson');
    expect(accepted.status, OfferStatus.accepted);
  });

  test('a rule error keeps the backend code and message', () async {
    final repo = ApiOffersRepository(
      api({
        'POST /api/offers/o_garson/reject': () =>
            fixture('error_offer_state', status: 409),
      }),
    );
    await expectLater(
      repo.reject('o_garson'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', 'OFFER_STATE')
            .having(
              (e) => e.message,
              'message',
              'Bu teklif daha önce yanıtlandı',
            )
            .having((e) => e.statusCode, 'status', 409),
      ),
    );
  });

  test('an unknown status is reported as a bad response', () async {
    final repo = ApiOffersRepository(
      api({
        'GET /api/offers/o_x': () => FakeAdapter.json({
          'ok': true,
          'data': {
            ...{'id': 'o_x', 'title': 'x', 'place': 'x', 'pay': '1'},
            ...{'logo': '/x', 'district': 'x', 'when': 'x', 'remain': 'x'},
            'status': 'archived',
            'expiresAt': '2026-09-27T07:03:00.000Z',
          },
        }),
      }),
    );
    await expectLater(
      repo.detail('o_x'),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'BAD_RESPONSE'),
      ),
    );
  });
}
