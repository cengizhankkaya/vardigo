import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offer.dart';
import '../../domain/repositories/i_offers_repository.dart';
import '../offers_repository_provider.dart';

/// One request with its city and branch note ("Detayları Gör").
class GetOfferDetail {
  const GetOfferDetail(this._repository);

  final IOffersRepository _repository;

  Future<Offer> call(String id) => _repository.detail(id);
}

final getOfferDetailProvider = Provider<GetOfferDetail>(
  (ref) => GetOfferDetail(ref.watch(offersRepositoryProvider)),
);
