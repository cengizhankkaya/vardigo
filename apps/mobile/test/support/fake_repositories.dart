import 'dart:async';

import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/features/appearance/domain/entities/app_theme_mode.dart';
import 'package:vardigo/features/appearance/domain/repositories/i_theme_mode_repository.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate_list.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate_offer_status.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate_sort.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate_tab.dart';
import 'package:vardigo/features/candidates/domain/repositories/i_candidates_repository.dart';
import 'package:vardigo/features/offers/domain/entities/offer.dart';
import 'package:vardigo/features/offers/domain/entities/offer_list.dart';
import 'package:vardigo/features/offers/domain/entities/offer_sort.dart';
import 'package:vardigo/features/offers/domain/entities/offer_status.dart';
import 'package:vardigo/features/offers/domain/entities/offer_tab.dart';
import 'package:vardigo/features/offers/domain/repositories/i_offers_repository.dart';
import 'package:vardigo/features/session/domain/entities/role.dart';
import 'package:vardigo/features/session/domain/entities/session.dart';
import 'package:vardigo/features/session/domain/repositories/i_session_repository.dart';

Candidate candidate(
  String id, {
  bool perfect = true,
  CandidateOfferStatus? offerStatus,
}) => Candidate(
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
  offerStatus: offerStatus,
);

/// In-memory candidates: w_merve and w_ferhat are perfect, w_derya and
/// w_ayse similar. [sendResult] decides how sending ends.
class FakeCandidatesRepository implements ICandidatesRepository {
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

  /// The pool fetch answers with; tests replace it to set request statuses.
  List<Candidate> pool = all;

  @override
  Future<CandidateList> fetch({CandidateTab? tab, CandidateSort? sort}) async {
    fetches.add((tab, sort));
    return CandidateList(
      totalPerfect: pool.where((c) => c.perfect).length,
      totalSimilar: pool.where((c) => !c.perfect).length,
      selectedHint: 1,
      candidates: [
        for (final c in pool)
          if (tab == null || c.perfect == (tab == CandidateTab.perfect)) c,
      ],
    );
  }

  @override
  Future<List<String>> sendInterviewRequests(List<String> workerIds) async {
    sent.add(workerIds);
    final error = sendError;
    if (error != null) throw error;
    final created =
        await (pendingSend?.future ??
            Future.value([for (final id in workerIds) 'o_$id']));
    // Like the server: each of them now has a request waiting for an answer.
    pool = [
      for (final c in pool)
        workerIds.contains(c.id)
            ? candidate(
                c.id,
                perfect: c.perfect,
                offerStatus: CandidateOfferStatus.pending,
              )
            : c,
    ];
    return created;
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
class FakeOffersRepository implements IOffersRepository {
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
class FakeSessionRepository implements ISessionRepository {
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

/// Theme choice kept in memory; starts on light like the real store.
class FakeThemeModeRepository implements IThemeModeRepository {
  AppThemeMode _mode = AppThemeMode.light;

  @override
  AppThemeMode read() => _mode;

  @override
  Future<void> write(AppThemeMode mode) async => _mode = mode;
}
