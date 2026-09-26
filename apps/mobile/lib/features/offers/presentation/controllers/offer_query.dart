import '../../domain/entities/offer_sort.dart';
import '../../domain/entities/offer_tab.dart';

typedef OfferQuery = ({OfferTab tab, OfferSort sort});

/// Tab and sort the screen opens with when the link names none.
const defaultOfferQuery = (tab: OfferTab.pending, sort: OfferSort.recommended);
