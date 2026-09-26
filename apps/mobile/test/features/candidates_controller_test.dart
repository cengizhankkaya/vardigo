import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/app/providers.dart';
import 'package:vardigo/core/error/exceptions/api_exception.dart';
import 'package:vardigo/features/candidates/presentation/controllers/candidates_controller.dart';
import 'package:vardigo/features/candidates/domain/entities/candidate.dart';

import '../support/fake_repositories.dart';

void main() {
  late FakeCandidatesRepository repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeCandidatesRepository();
    container = ProviderContainer(
      overrides: [candidatesRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);
    // Keep the auto-dispose controller alive like the screen does.
    container.listen(
      candidatesControllerProvider(defaultCandidateQuery),
      (_, _) {},
    );
  });

  CandidatesController controller() => container.read(
    candidatesControllerProvider(defaultCandidateQuery).notifier,
  );
  CandidatesState state() =>
      container.read(candidatesControllerProvider(defaultCandidateQuery));

  Future<CandidateList> load() =>
      container.read(candidateListProvider(state().query).future);

  test('starts on the perfect tab, recommended sort, nothing selected', () {
    expect(state().tab, CandidateTab.perfect);
    expect(state().sort, CandidateSort.recommended);
    expect(state().selected, isEmpty);
  });

  test('preselects the first candidate once', () async {
    controller().applyInitialSelection(await load());
    expect(state().selected, {'w_merve'});

    controller().toggle('w_merve');
    controller().applyInitialSelection(await load());
    expect(state().selected, isEmpty);
  });

  test('keeps the selection across tabs', () async {
    controller().toggle('w_merve');
    controller().selectTab(CandidateTab.similar);
    controller().toggle('w_derya');
    expect(state().selected, {'w_merve', 'w_derya'});
    expect((await load()).candidates.map((c) => c.id), ['w_derya', 'w_ayse']);
  });

  test('cycles the sort through all options', () {
    controller().cycleSort();
    expect(state().sort, CandidateSort.near);
    controller().cycleSort();
    expect(state().sort, CandidateSort.rating);
    controller().cycleSort();
    expect(state().sort, CandidateSort.recommended);
  });

  test('sends the selection and clears only what was sent', () async {
    controller()
      ..toggle('w_merve')
      ..toggle('w_derya');
    final result = await controller().submit();
    expect(result, isA<SubmitSucceeded>().having((r) => r.count, 'count', 2));
    expect(repo.sent.single, ['w_merve', 'w_derya']);
    expect(state().selected, isEmpty);
    expect(state().submitting, isFalse);
  });

  test('locks the controls while sending', () async {
    repo.pendingSend = Completer();
    controller().toggle('w_merve');
    final result = controller().submit();
    expect(state().submitting, isTrue);

    controller()
      ..toggle('w_derya')
      ..selectTab(CandidateTab.similar)
      ..cycleSort();
    expect(await controller().submit(), isNull);
    expect(state().selected, {'w_merve'});
    expect(state().tab, CandidateTab.perfect);
    expect(state().sort, CandidateSort.recommended);
    expect(repo.sent, hasLength(1));

    repo.pendingSend!.complete(['o_1']);
    await result;
    expect(state().submitting, isFalse);
  });

  test('sends nothing without a selection', () async {
    expect(await controller().submit(), isNull);
    expect(repo.sent, isEmpty);
  });

  test('keeps the selection when the server refuses', () async {
    repo.sendError = const ApiException(
      code: 'OFFER_PENDING_EXISTS',
      message: 'Seçilen personel için açık teklif var: w_merve',
      statusCode: 409,
    );
    controller().toggle('w_merve');
    final result = await controller().submit();
    expect(
      result,
      isA<SubmitFailed>().having((r) => r.uncertain, 'uncertain', false),
    );
    expect(state().selected, {'w_merve'});
  });

  test('marks a lost connection as uncertain and does not retry', () async {
    repo.sendError = const ApiException(
      code: ApiException.timeout,
      message: '',
    );
    controller().toggle('w_merve');
    final result = await controller().submit();
    expect(
      result,
      isA<SubmitFailed>().having((r) => r.uncertain, 'uncertain', true),
    );
    expect(repo.sent, hasLength(1));
    expect(state().selected, {'w_merve'});
  });

  test('an answer after leaving the screen is dropped quietly', () async {
    final local = ProviderContainer(
      overrides: [candidatesRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(local.dispose);
    final sub = local.listen(
      candidatesControllerProvider(defaultCandidateQuery),
      (_, _) {},
    );
    repo.pendingSend = Completer();
    final notifier = local.read(
      candidatesControllerProvider(defaultCandidateQuery).notifier,
    )..toggle('w_merve');
    final result = notifier.submit();

    sub.close();
    await Future<void>.delayed(Duration.zero);
    repo.pendingSend!.complete(['o_1']);

    expect(await result, isA<SubmitSucceeded>());
  });
}
