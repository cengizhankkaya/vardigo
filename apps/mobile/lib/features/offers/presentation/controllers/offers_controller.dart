import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/offers_revision.dart';
import '../../application/usecases/get_offer_detail.dart';
import '../../application/usecases/get_offers.dart';
import '../../application/usecases/respond_to_offer.dart';
import '../../../../core/error/exceptions/api_exception.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/offer_list.dart';
import '../../domain/entities/offer_sort.dart';
import '../../domain/entities/offer_tab.dart';
import 'offer_query.dart';
import 'offers_state.dart';
import 'respond_result.dart';

/// Current time; tests replace it.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Ticks so countdowns move without asking the server.
final countdownTickProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final now = ref.watch(clockProvider);
  return Stream.periodic(const Duration(seconds: 30), (_) => now());
});

/// Reloads after every answer ([offersRevisionProvider]).
final offerListProvider = FutureProvider.autoDispose
    .family<OfferList, OfferQuery>((ref, query) {
      ref.watch(offersRevisionProvider);
      return ref.watch(getOffersProvider)(tab: query.tab, sort: query.sort);
    });

/// City and branch note shown under "Detayları Gör".
final offerDetailProvider = FutureProvider.autoDispose.family<Offer, String>(
  (ref, id) => ref.watch(getOfferDetailProvider)(id),
);

/// One controller per screen visit, keyed by the tab and sort it opens with
/// (from the route, e.g. `?tab=...`).
final offersControllerProvider = NotifierProvider.autoDispose
    .family<OffersController, OffersState, OfferQuery>(OffersController.new);

class OffersController extends Notifier<OffersState> {
  OffersController(this.opening);

  final OfferQuery opening;

  @override
  OffersState build() => OffersState(tab: opening.tab, sort: opening.sort);

  void selectTab(OfferTab tab) => state = state.copyWith(tab: tab);

  /// Önerilen → Süresi Yakın → Ücret → Önerilen.
  void cycleSort() {
    const values = OfferSort.values;
    state = state.copyWith(
      sort: values[(values.indexOf(state.sort) + 1) % values.length],
    );
  }

  void toggleDetails(String id) {
    final expanded = {...state.expanded};
    if (!expanded.remove(id)) expanded.add(id);
    state = state.copyWith(expanded: expanded);
  }

  /// "İlgileniyorum" ([accept] true) or "İlgilenmiyorum". [RespondToOffer]
  /// reloads the lists, even when this screen has closed by then.
  Future<RespondResult> respond(Offer offer, {required bool accept}) async {
    if (state.busy.contains(offer.id)) return RespondFailed(_busy);
    state = state.copyWith(busy: {...state.busy, offer.id});
    try {
      final updated = await ref.read(respondToOfferProvider)(
        offer.id,
        accept: accept,
      );
      return Responded(updated);
    } on ApiException catch (error) {
      return RespondFailed(error);
    } finally {
      // The screen may have closed while waiting; its busy mark went with it.
      if (ref.mounted) {
        state = state.copyWith(busy: {...state.busy}..remove(offer.id));
      }
    }
  }

  static const _busy = ApiException(code: 'BUSY', message: '');
}
