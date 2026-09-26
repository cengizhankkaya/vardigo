import 'offer_status.dart';

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

  /// Time left at [now]; never negative.
  Duration remainingAt(DateTime now) {
    final left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  /// Less than [urgentBelow] left: the countdown turns red (reference card 1).
  bool isUrgentAt(DateTime now) => isPending && remainingAt(now) < urgentBelow;

  static const urgentBelow = Duration(hours: 6);
}
