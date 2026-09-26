import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../shared/design_system/components/error_view.dart';
import '../../../shared/design_system/tokens/app_dimens.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/async_list_view.dart';
import '../application/offers_controller.dart';
import '../domain/offer.dart';
import 'offer_labels.dart';
import 'widgets/card/offer_card.dart';
import 'widgets/offer_sort_row.dart';
import 'widgets/offer_tabs.dart';
import 'widgets/offers_header.dart';

/// Job seeker screen "Görüşme Talepleri". Reads the providers and hands
/// plain values and callbacks to the widgets below it.
class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Offers may have expired while the app was in the background.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(offerListProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersControllerProvider);
    final controller = ref.read(offersControllerProvider.notifier);
    final list = ref.watch(offerListProvider(state.query));
    final now =
        ref.watch(countdownTickProvider).value ?? ref.watch(clockProvider)();

    // When a pending countdown reaches zero, let the server mark it expired.
    ref.listen(countdownTickProvider, (_, tick) {
      final time = tick.value;
      final offers = list.value?.offers ?? const <Offer>[];
      if (time != null &&
          offers.any(
            (o) => o.isPending && o.remainingAt(time) == Duration.zero,
          )) {
        ref.invalidate(offerListProvider);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            OffersHeader(
              tab: state.tab,
              pendingCount: list.value?.pendingCount,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                16,
                AppSpacing.page,
                0,
              ),
              child: OfferTabs(tab: state.tab, onTab: controller.selectTab),
            ),
            Expanded(
              child: AsyncListView<OfferList>(
                value: list,
                header: [
                  OfferSortRow(sort: state.sort, onSort: controller.cycleSort),
                ],
                itemGap: AppSpacing.offerCardGap,
                emptyText: state.tab.emptyText(context.l10n),
                onRefresh: () =>
                    ref.refresh(offerListProvider(state.query).future),
                onRetry: () => ref.invalidate(offerListProvider(state.query)),
                itemsBuilder: (data) => [
                  for (final offer in data.offers)
                    OfferCard(
                      offer: offer,
                      now: now,
                      busy: state.busy.contains(offer.id),
                      expanded: state.expanded.contains(offer.id),
                      onAccept: () => _respond(offer, accept: true),
                      onReject: () => _respond(offer, accept: false),
                      onToggleDetails: () => controller.toggleDetails(offer.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respond(Offer offer, {required bool accept}) async {
    final result = await ref
        .read(offersControllerProvider.notifier)
        .respond(offer, accept: accept);
    if (!mounted) return;
    final l10n = context.l10n;
    showAppSnackBar(context, switch (result) {
      Responded(offer: final o) when o.status == OfferStatus.accepted =>
        l10n.offerAccepted(o.title),
      Responded(offer: final o) => l10n.offerRejected(o.title),
      RespondFailed(:final error) => errorText(context, error),
    });
  }
}
