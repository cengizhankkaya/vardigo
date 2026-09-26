import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offer_list.dart';
import '../../domain/entities/offer_sort.dart';
import '../../domain/entities/offer_tab.dart';
import '../../domain/repositories/i_offers_repository.dart';
import '../offers_repository_provider.dart';

/// The job seeker's interview requests on one tab, in one sort order.
class GetOffers {
  const GetOffers(this._repository);

  final IOffersRepository _repository;

  Future<OfferList> call({OfferTab tab = OfferTab.pending, OfferSort? sort}) =>
      _repository.fetch(tab: tab, sort: sort);
}

final getOffersProvider = Provider<GetOffers>(
  (ref) => GetOffers(ref.watch(offersRepositoryProvider)),
);
