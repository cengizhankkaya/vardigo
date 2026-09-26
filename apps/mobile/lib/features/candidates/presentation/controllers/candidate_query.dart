import '../../domain/entities/candidate_sort.dart';
import '../../domain/entities/candidate_tab.dart';

typedef CandidateQuery = ({CandidateTab tab, CandidateSort sort});

/// Tab and sort the screen opens with when the link names none.
const defaultCandidateQuery = (
  tab: CandidateTab.perfect,
  sort: CandidateSort.recommended,
);
