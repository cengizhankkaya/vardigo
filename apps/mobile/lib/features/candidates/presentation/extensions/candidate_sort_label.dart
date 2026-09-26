import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/candidate_sort.dart';

extension CandidateSortLabel on CandidateSort {
  /// "Önerilen", "En Yakın", "Puan".
  String label(AppLocalizations l10n) => switch (this) {
    CandidateSort.recommended => l10n.sortRecommended,
    CandidateSort.near => l10n.sortNear,
    CandidateSort.rating => l10n.sortRating,
  };
}
