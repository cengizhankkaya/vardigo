import 'dart:async';

import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate.dart';
import 'package:vardigo/features/offers/domain/entities/offer.dart';
import 'package:vardigo/features/session/domain/entities/session.dart';

Candidate candidate(String id, {bool perfect = true}) => Candidate(
  id: id,
  name: id,
  rating: '4.9',
  attendance: '%100 katılım',
  distance: '4.9 km',
  photoPath: '/assets/photos/$id.png',
  online: true,
  perfect: perfect,
  score: perfect ? 90 : 70,
  expectedPay: '25.000',
  payCompatible: perfect,
);

/// In-memory candidates: w_merve and w_ferhat are perfect, w_derya and
/// w_ayse similar. [sendResult] decides how sending ends.
class FakeCandidatesRepository implements CandidatesRepository {
  final fetches = <(CandidateTab?, CandidateSort?)>[];
  final sent = <List<String>>[];
  Completer<List<String>>? pendingSend;
  Object? sendError;

  static final all = [
    candidate('w_merve'),
    candidate('w_ferhat'),
    candidate('w_derya', perfect: false),
    candidate('w_ayse', perfect: false),
  ];

  @override
  Future<CandidateList> fetch({CandidateTab? tab, CandidateSort? sort}) async {
    fetches.add((tab, sort));
    return CandidateList(
      totalPerfect: 26,
      totalSimilar: 16,
      selectedHint: 1,
      candidates: [
        for (final c in all)
          if (tab == null || c.perfect == (tab == CandidateTab.perfect)) c,
      ],
    );
  }

  @override
  Future<List<String>> sendInterviewRequests(List<String> workerIds) async {
    sent.add(workerIds);
    final error = sendError;
    if (error != null) throw error;
    final pending = pendingSend;
    if (pending != null) return pending.future;
    return [for (final id in workerIds) 'o_$id'];
  }
}

final testNow = DateTime.utc(2026, 9, 26, 10);

Offer offer(
  String id, {
  OfferStatus status = OfferStatus.pending,
  Duration left = const Duration(hours: 21, minutes: 32),
  String pay = '45.000',
}) => Offer(
  id: id,
  title: id,
  place: 'Zarif Cheff Restaurant',
  pay: pay,
  logoPath: '/assets/logos/zarif.svg',
  district: 'Kadıköy',
  when: '16 Ağu · 12:00 - 16:00',
  status: status,
  remain: '21 saat 32 dakika',
  expiresAt: testNow.add(left),
  city: 'İstanbul',
  note: 'Şube: Sinanpaşa Mah.',
);

/// In-memory inbox. Answering moves an offer to the answered tab.
class FakeOffersRepository implements OffersRepository {
  final offers = <String, Offer>{
    'o_garson': offer('o_garson', left: const Duration(hours: 5, minutes: 32)),
    'o_barista': offer('o_barista', pay: '38.000'),
    'o_komi': offer('o_komi', status: OfferStatus.expired, left: Duration.zero),
  };
  final fetches = <(OfferTab, OfferSort?)>[];
  Object? respondError;

  /// When set, accept/reject wait for it before answering.
  Completer<void>? pendingRespond;

  @override
  Future<OfferList> fetch({
    OfferTab tab = OfferTab.pending,
    OfferSort? sort,
  }) async {
    fetches.add((tab, sort));
    bool inTab(Offer o) => switch (tab) {
      OfferTab.pending => o.status == OfferStatus.pending,
      OfferTab.answered =>
        o.status == OfferStatus.accepted || o.status == OfferStatus.rejected,
      OfferTab.expired => o.status == OfferStatus.expired,
    };
    return OfferList(
      pendingCount: offers.values.where((o) => o.isPending).length,
      pendingCountLabel: 12,
      offers: offers.values.where(inTab).toList(),
    );
  }

  @override
  Future<Offer> detail(String id) async => offers[id]!;

  @override
  Future<Offer> accept(String id) => _answer(id, OfferStatus.accepted);

  @override
  Future<Offer> reject(String id) => _answer(id, OfferStatus.rejected);

  Future<Offer> _answer(String id, OfferStatus status) async {
    final pending = pendingRespond;
    if (pending != null) await pending.future;
    final error = respondError;
    if (error != null) throw error;
    final old = offers[id]!;
    return offers[id] = Offer(
      id: old.id,
      title: old.title,
      place: old.place,
      pay: old.pay,
      logoPath: old.logoPath,
      district: old.district,
      when: old.when,
      status: status,
      remain: old.remain,
      expiresAt: old.expiresAt,
    );
  }
}

/// Demo login that fails the first [failures] times with a connection
/// problem, then hands out `dev-<role>` tokens.
class FakeSessionRepository implements SessionRepository {
  FakeSessionRepository({this.failures = 0});

  int failures;
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
