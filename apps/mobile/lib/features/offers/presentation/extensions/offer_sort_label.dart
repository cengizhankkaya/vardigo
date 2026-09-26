import '../../../../core/l10n/l10n.dart';
import '../../domain/entities/offer_sort.dart';

extension OfferSortLabel on OfferSort {
  /// "Önerilen", "Süresi Yakın", "Ücret".
  String label(AppLocalizations l10n) => switch (this) {
    OfferSort.recommended => l10n.sortRecommended,
    OfferSort.expiring => l10n.sortExpiring,
    OfferSort.pay => l10n.sortPay,
  };
}
