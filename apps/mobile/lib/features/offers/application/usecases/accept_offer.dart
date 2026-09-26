import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offer.dart';
import '../../domain/repositories/i_offers_repository.dart';
import '../offers_repository_provider.dart';

/// "İlgileniyorum": returns the request with its new status.
class AcceptOffer {
  const AcceptOffer(this._repository);

  final IOffersRepository _repository;

  Future<Offer> call(String id) => _repository.accept(id);
}

final acceptOfferProvider = Provider<AcceptOffer>(
  (ref) => AcceptOffer(ref.watch(offersRepositoryProvider)),
);
