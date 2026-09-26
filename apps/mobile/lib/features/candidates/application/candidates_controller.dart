import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/network/api_exception.dart';
import '../domain/candidate.dart';

typedef CandidateQuery = ({CandidateTab tab, CandidateSort sort});

/// One list per tab + sort. Switching back and forth reuses loaded lists;
/// an answer for an old tab never shows up under the current one.
final candidateListProvider = FutureProvider.autoDispose
    .family<CandidateList, CandidateQuery>(
      (ref, query) => ref
          .watch(candidatesRepositoryProvider)
          .fetch(tab: query.tab, sort: query.sort),
    );

/// Tab and sort the screen opens with when the link names none.
const defaultCandidateQuery = (
  tab: CandidateTab.perfect,
  sort: CandidateSort.recommended,
);

/// One controller per screen visit, keyed by the tab and sort it opens with
/// (from the route, e.g. `?tab=...`).
final candidatesControllerProvider = NotifierProvider.autoDispose
    .family<CandidatesController, CandidatesState, CandidateQuery>(
      CandidatesController.new,
    );

class CandidatesState {
  const CandidatesState({
    this.tab = CandidateTab.perfect,
    this.sort = CandidateSort.recommended,
    this.selected = const {},
    this.submitting = false,
    this.initialSelectionApplied = false,
  });

  final CandidateTab tab;
  final CandidateSort sort;

  /// Selected candidate ids across both tabs, in selection order.
  final Set<String> selected;
  final bool submitting;
  final bool initialSelectionApplied;

  CandidateQuery get query => (tab: tab, sort: sort);

  CandidatesState copyWith({
    CandidateTab? tab,
    CandidateSort? sort,
    Set<String>? selected,
    bool? submitting,
    bool? initialSelectionApplied,
  }) => CandidatesState(
    tab: tab ?? this.tab,
    sort: sort ?? this.sort,
    selected: selected ?? this.selected,
    submitting: submitting ?? this.submitting,
    initialSelectionApplied:
        initialSelectionApplied ?? this.initialSelectionApplied,
  );
}

sealed class SubmitResult {
  const SubmitResult();
}

class SubmitSucceeded extends SubmitResult {
  const SubmitSucceeded(this.count);
  final int count;
}

class SubmitFailed extends SubmitResult {
  const SubmitFailed(this.error);
  final ApiException error;

  /// No answer from the server: the requests may or may not exist.
  bool get uncertain => error.isConnectionProblem;
}

class CandidatesController extends Notifier<CandidatesState> {
  CandidatesController(this.opening);

  final CandidateQuery opening;

  @override
  CandidatesState build() =>
      CandidatesState(tab: opening.tab, sort: opening.sort);

  void selectTab(CandidateTab tab) {
    if (state.submitting) return;
    state = state.copyWith(tab: tab);
  }

  /// Önerilen → En Yakın → Puan → Önerilen.
  void cycleSort() {
    if (state.submitting) return;
    const values = CandidateSort.values;
    state = state.copyWith(
      sort: values[(values.indexOf(state.sort) + 1) % values.length],
    );
  }

  void toggle(String id) {
    if (state.submitting) return;
    final selected = {...state.selected};
    if (!selected.remove(id)) selected.add(id);
    state = state.copyWith(selected: selected);
  }

  /// The reference opens with Merve selected; the API says how many of the
  /// first candidates to preselect. Applied once per screen visit.
  void applyInitialSelection(CandidateList list) {
    if (state.initialSelectionApplied) return;
    state = state.copyWith(
      selected: {
        ...state.selected,
        ...list.candidates.take(list.selectedHint).map((c) => c.id),
      },
      initialSelectionApplied: true,
    );
  }

  /// Sends the current selection once. Never retries on its own: after a
  /// timeout the server may already have created the requests.
  /// Returns null when nothing was sent (empty selection or a send in flight).
  Future<SubmitResult?> submit() async {
    if (state.submitting || state.selected.isEmpty) return null;
    final ids = state.selected.toList();
    state = state.copyWith(submitting: true);
    try {
      final created = await ref
          .read(candidatesRepositoryProvider)
          .sendInterviewRequests(ids);
      // The screen may have closed while waiting; the result still goes back.
      if (ref.mounted) {
        state = state.copyWith(
          submitting: false,
          selected: {...state.selected}..removeAll(ids),
        );
      }
      return SubmitSucceeded(created.length);
    } on ApiException catch (error) {
      if (ref.mounted) {
        state = state.copyWith(submitting: false);
        if (error.code == 'CANDIDATE_NOT_FOUND') {
          ref.invalidate(candidateListProvider);
        }
      }
      return SubmitFailed(error);
    }
  }
}
