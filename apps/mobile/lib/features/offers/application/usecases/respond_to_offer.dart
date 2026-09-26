import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/offer.dart';
import '../../domain/repositories/i_offers_repository.dart';
import '../offers_repository_provider.dart';
import '../offers_revision.dart';

/// "İlgileniyorum" ([accept] true) or "İlgilenmiyorum": returns the request
/// with its new status. Either way the lists reload afterwards: the request
/// moved tabs, or the server refused it for a reason the list should show.
class RespondToOffer {
  const RespondToOffer(this._repository, this._revision);

  final IOffersRepository _repository;
  final OffersRevision _revision;

  Future<Offer> call(String id, {required bool accept}) async {
    try {
      return accept
          ? await _repository.accept(id)
          : await _repository.reject(id);
    } finally {
      _revision.bump();
    }
  }
}

final respondToOfferProvider = Provider<RespondToOffer>(
  (ref) => RespondToOffer(
    ref.watch(offersRepositoryProvider),
    ref.watch(offersRevisionProvider.notifier),
  ),
);
