import '../../../l10n/l10n.dart';
import '../domain/offer.dart';

extension OfferSortLabel on OfferSort {
  /// "Önerilen", "Süresi Yakın", "Ücret".
  String label(AppLocalizations l10n) => switch (this) {
    OfferSort.recommended => l10n.sortRecommended,
    OfferSort.expiring => l10n.sortExpiring,
    OfferSort.pay => l10n.sortPay,
  };
}

extension OfferTabLabels on OfferTab {
  /// "Bekleyen", "Cevaplanan", "Süresi Dolan".
  String label(AppLocalizations l10n) => switch (this) {
    OfferTab.pending => l10n.tabPending,
    OfferTab.answered => l10n.tabAnswered,
    OfferTab.expired => l10n.tabExpired,
  };

  /// Shown when the tab has no offers.
  String emptyText(AppLocalizations l10n) => switch (this) {
    OfferTab.pending => l10n.emptyPending,
    OfferTab.answered => l10n.emptyAnswered,
    OfferTab.expired => l10n.emptyExpired,
  };
}
