import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/square_icon_button.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_sizes.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/offer_tab.dart';

/// Back button, "Görüşme Talepleri" and a subtitle for the active tab.
/// [pendingCount] is null until the first list arrives.
class OffersHeader extends StatelessWidget {
  const OffersHeader({
    super.key,
    required this.tab,
    required this.pendingCount,
  });

  final OfferTab tab;
  final int? pendingCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pendingCount = this.pendingCount;
    final subtitle = switch (tab) {
      OfferTab.pending =>
        pendingCount == null ? '' : l10n.offersPendingSubtitle(pendingCount),
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
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.offersTitle, style: context.textStyles.title20),
                Text(subtitle, style: context.textStyles.caption12),
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
