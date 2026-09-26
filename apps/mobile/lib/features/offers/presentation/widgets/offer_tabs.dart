import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/pill_tabs.dart';
import '../../../../core/presentation/widgets/pill_tabs_style.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_shadows.dart';
import '../../domain/entities/offer_tab.dart';
import '../extensions/offer_tab_labels.dart';

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
