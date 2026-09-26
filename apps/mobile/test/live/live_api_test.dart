@Tags(['live'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/composition_root.dart';
import 'package:vardigo/core/api/api_config.dart';
import 'package:vardigo/core/api/api_providers.dart';
import 'package:vardigo/features/candidates/application/candidates_repository_provider.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate_tab.dart';
import 'package:vardigo/features/offers/application/offers_repository_provider.dart';
import 'package:vardigo/features/offers/domain/entities/offer_status.dart';
import 'package:vardigo/features/offers/domain/entities/offer_tab.dart';
import 'package:vardigo/features/session/domain/entities/role.dart';
import 'package:vardigo/features/session/presentation/controllers/session_controller.dart';

/// Runs the case flow through the app's repositories against a real server:
/// LIVE_API_ORIGIN=http://127.0.0.1:3000 flutter test test/live
/// (start the backend with `npm run db:reset && npm run dev` first).
void main() {
  final origin = Platform.environment['LIVE_API_ORIGIN'];

  test(
    'employer sends, worker answers',
    () async {
      final container = ProviderContainer(
        overrides: [
          ...apiAdapters,
          apiConfigProvider.overrideWithValue(ApiConfig(origin!)),
        ],
      );
      addTearDown(container.dispose);
      final session = container.read(sessionProvider.notifier);

      await session.login(Role.employer);
      final candidates = container.read(candidatesRepositoryProvider);
      final list = await candidates.fetch();
      expect(list.candidates, hasLength(4));
      final perfect = await candidates.fetch(tab: CandidateTab.perfect);
      expect(perfect.candidates.every((c) => c.perfect), isTrue);

      final ids = [list.candidates[0].id, list.candidates[1].id];
      final created = await candidates.sendInterviewRequests(ids);
      expect(created, hasLength(2));

      await session.login(Role.worker);
      final offers = container.read(offersRepositoryProvider);
      final pending = await offers.fetch();
      expect(pending.offers.map((o) => o.id), containsAll(created));

      expect((await offers.accept(created[0])).status, OfferStatus.accepted);
      expect((await offers.reject(created[1])).status, OfferStatus.rejected);
      final answered = await offers.fetch(tab: OfferTab.answered);
      expect(answered.offers.map((o) => o.id), containsAll(created));
    },
    skip: origin == null
        ? 'set LIVE_API_ORIGIN to run against a server'
        : false,
  );
}
