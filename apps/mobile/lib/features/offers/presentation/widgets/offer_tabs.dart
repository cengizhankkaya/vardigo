import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/pill_tabs.dart';
import '../../../../shared/design_system/theme/theme.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';
import '../../domain/offer.dart';
import '../offer_labels.dart';

/// Bekleyen / Cevaplanan / Süresi Dolan.
class OfferTabs extends StatelessWidget {
  const OfferTabs({super.key, required this.tab, required this.onTab});

  final OfferTab tab;
  final ValueChanged<OfferTab> onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    return PillTabs(
      tabs: [for (final value in OfferTab.values) (value, value.label(l10n))],
      selected: tab,
      onSelected: onTab,
      style: PillTabsStyle(
        background: colors.tabTrackSoft,
        radius: 54,
        pillRadius: 26,
        pillPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        activeColor: colors.tabPillActive,
        activeShadow: AppShadows.offerTabActive,
        textStyle: context.textStyles.tab13,
        activeTextColor: colors.textStrong,
        inactiveTextColor: colors.textSoft,
        gap: 4,
      ),
    );
  }
}
