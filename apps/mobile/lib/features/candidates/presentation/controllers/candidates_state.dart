import '../../domain/entities/candidate_sort.dart';
import '../../domain/entities/candidate_tab.dart';
import 'candidate_query.dart';

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
