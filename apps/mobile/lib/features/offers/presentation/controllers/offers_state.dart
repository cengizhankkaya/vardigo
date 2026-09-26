import '../../domain/entities/offer_sort.dart';
import '../../domain/entities/offer_tab.dart';
import 'offer_query.dart';

class OffersState {
  const OffersState({
    this.tab = OfferTab.pending,
    this.sort = OfferSort.recommended,
    this.busy = const {},
    this.expanded = const {},
  });

  final OfferTab tab;
  final OfferSort sort;

  /// Offers with an accept/reject call in flight.
  final Set<String> busy;

  /// Offers with their details open.
  final Set<String> expanded;

  OfferQuery get query => (tab: tab, sort: sort);

  OffersState copyWith({
    OfferTab? tab,
    OfferSort? sort,
    Set<String>? busy,
    Set<String>? expanded,
  }) => OffersState(
    tab: tab ?? this.tab,
    sort: sort ?? this.sort,
    busy: busy ?? this.busy,
    expanded: expanded ?? this.expanded,
  );
}
