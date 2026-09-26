enum OfferStatus { pending, accepted, rejected, expired }

/// Tabs on the job seeker screen; `answered` covers accepted and rejected.
enum OfferTab { pending, answered, expired }

enum OfferSort { recommended, expiring, pay }

class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.place,
    required this.pay,
    required this.logoPath,
    required this.district,
    required this.when,
    required this.status,
    required this.remain,
    required this.expiresAt,
    this.city,
    this.note,
  });

  final String id;
  final String title;
  final String place;

  /// "45.000", formatted by the API.
  final String pay;

  /// Server path such as `/assets/logos/zarif.svg`.
  final String logoPath;
  final String district;

  /// "16 Ağu · 12:00 - 16:00", shown as sent.
  final String when;
  final OfferStatus status;

  /// "21 saat 32 dakika" at the time of the response.
  final String remain;
  final DateTime expiresAt;

  /// Only filled by the detail endpoint.
  final String? city;
  final String? note;

  bool get isPending => status == OfferStatus.pending;
}

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

abstract interface class OffersRepository {
  Future<OfferList> fetch({OfferTab tab = OfferTab.pending, OfferSort? sort});

  Future<Offer> detail(String id);

  /// "İlgileniyorum". Returns the offer with its new status.
  Future<Offer> accept(String id);

  /// "İlgilenmiyorum". Returns the offer with its new status.
  Future<Offer> reject(String id);
}
