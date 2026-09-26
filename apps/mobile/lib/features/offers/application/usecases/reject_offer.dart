import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offer.dart';
import '../../domain/repositories/i_offers_repository.dart';
import '../offers_repository_provider.dart';

/// "İlgilenmiyorum": returns the request with its new status.
class RejectOffer {
  const RejectOffer(this._repository);

  final IOffersRepository _repository;

  Future<Offer> call(String id) => _repository.reject(id);
}

final rejectOfferProvider = Provider<RejectOffer>(
  (ref) => RejectOffer(ref.watch(offersRepositoryProvider)),
);
