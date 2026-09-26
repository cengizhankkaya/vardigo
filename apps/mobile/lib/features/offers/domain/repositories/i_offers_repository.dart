import '../entities/offer.dart';
import '../entities/offer_list.dart';
import '../entities/offer_sort.dart';
import '../entities/offer_tab.dart';

abstract interface class IOffersRepository {
  Future<OfferList> fetch({OfferTab tab = OfferTab.pending, OfferSort? sort});

  Future<Offer> detail(String id);

  /// "İlgileniyorum". Returns the offer with its new status.
  Future<Offer> accept(String id);

  /// "İlgilenmiyorum". Returns the offer with its new status.
  Future<Offer> reject(String id);
}
