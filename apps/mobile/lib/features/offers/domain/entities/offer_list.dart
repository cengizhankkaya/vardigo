import 'offer.dart';

class OfferList {
  const OfferList({
    required this.pendingCount,
    required this.pendingCountLabel,
    required this.offers,
  });

  /// Real number of pending offers.
  final int pendingCount;

  /// Fixed header number from the reference design (12).
  final int pendingCountLabel;
  final List<Offer> offers;
}
