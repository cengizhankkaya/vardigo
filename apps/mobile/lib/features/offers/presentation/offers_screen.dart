import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/design_system/components/error_view.dart';
import '../../../shared/design_system/components/sort_chip.dart';
import '../../../shared/design_system/components/square_icon_button.dart';
import '../../../shared/design_system/tokens/app_dimens.dart';
import '../../../shared/design_system/tokens/app_shadows.dart';
import '../../../shared/design_system/tokens/app_text_styles.dart';
import '../application/offers_controller.dart';
import '../domain/offer.dart';
import 'widgets/offer_card.dart';

/// Job seeker screen "Görüşme Talepleri".
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

    final pendingCount = list.value?.pendingCount;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(tab: state.tab, pendingCount: pendingCount),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                16,
                AppSpacing.page,
                0,
              ),
              child: _Tabs(tab: state.tab, onTab: controller.selectTab),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(offerListProvider(state.query).future),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    8,
                    AppSpacing.page,
                    16,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SortChip(
                          label: context.l10n.sortLabel(
                            _sortName(context, state.sort),
                          ),
                          onPressed: controller.cycleSort,
                        ),
                      ),
                    ),
                    ...list.when(
                      skipLoadingOnRefresh: true,
                      data: (data) => data.offers.isEmpty
                          ? [_Empty(_emptyText(context, state.tab))]
                          : [
                              for (final offer in data.offers)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.offerCardGap,
                                  ),
                                  child: OfferCard(
                                    offer: offer,
                                    now: now,
                                    busy: state.busy.contains(offer.id),
                                    expanded: state.expanded.contains(offer.id),
                                    onAccept: () =>
                                        _respond(offer, accept: true),
                                    onReject: () =>
                                        _respond(offer, accept: false),
                                    onToggleDetails: () =>
                                        controller.toggleDetails(offer.id),
                                  ),
                                ),
                            ],
                      loading: () => const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ],
                      error: (error, _) => [
                        ErrorView(
                          error: error,
                          onRetry: () =>
                              ref.invalidate(offerListProvider(state.query)),
                        ),
                      ],
                    ),
                  ],
                ),
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
    final message = switch (result) {
      Responded(offer: final o) when o.status == OfferStatus.accepted =>
        l10n.offerAccepted(o.title),
      Responded(offer: final o) => l10n.offerRejected(o.title),
      RespondFailed(:final error) => errorText(context, error),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String _sortName(BuildContext context, OfferSort sort) {
    final l10n = context.l10n;
    return switch (sort) {
      OfferSort.recommended => l10n.sortRecommended,
      OfferSort.expiring => l10n.sortExpiring,
      OfferSort.pay => l10n.sortPay,
    };
  }

  static String _emptyText(BuildContext context, OfferTab tab) {
    final l10n = context.l10n;
    return switch (tab) {
      OfferTab.pending => l10n.emptyPending,
      OfferTab.answered => l10n.emptyAnswered,
      OfferTab.expired => l10n.emptyExpired,
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tab, required this.pendingCount});

  final OfferTab tab;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = switch (tab) {
      OfferTab.pending =>
        pendingCount == null ? '' : l10n.offersPendingSubtitle(pendingCount!),
      OfferTab.answered => l10n.offersAnsweredSubtitle,
      OfferTab.expired => l10n.offersExpiredSubtitle,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        12,
        AppSpacing.page,
        8,
      ),
      child: Row(
        children: [
          SquareIconButton(
            icon: Assets.icons.back,
            label: l10n.back,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.offersTitle, style: AppTextStyles.title20),
                Text(subtitle, style: AppTextStyles.caption12),
              ],
            ),
          ),
          // The reference keeps this side empty to balance the back button.
          const SizedBox(width: AppSizes.squareButton),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.tab, required this.onTab});

  final OfferTab tab;
  final ValueChanged<OfferTab> onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ColorName.weak50,
        borderRadius: BorderRadius.circular(54),
      ),
      child: Row(
        children: [
          _pill(OfferTab.pending, l10n.tabPending),
          const SizedBox(width: 4),
          _pill(OfferTab.answered, l10n.tabAnswered),
          const SizedBox(width: 4),
          _pill(OfferTab.expired, l10n.tabExpired),
        ],
      ),
    );
  }

  Widget _pill(OfferTab value, String label) {
    final active = value == tab;
    return Expanded(
      child: Semantics(
        selected: active,
        button: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTab(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? ColorName.white : null,
              borderRadius: BorderRadius.circular(26),
              boxShadow: active ? AppShadows.offerTabActive : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.tab13.copyWith(
                color: active ? ColorName.strong : ColorName.soft,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.label14.copyWith(
          color: ColorName.sub,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
