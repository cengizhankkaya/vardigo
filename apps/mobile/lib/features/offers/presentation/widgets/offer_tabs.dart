import 'package:flutter/material.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/pill_tabs.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';
import '../../domain/offer.dart';
import '../offer_labels.dart';

/// Bekleyen / Cevaplanan / Süresi Dolan.
class OfferTabs extends StatelessWidget {
  const OfferTabs({super.key, required this.tab, required this.onTab});

  final OfferTab tab;
  final ValueChanged<OfferTab> onTab;

  static const _style = PillTabsStyle(
    background: ColorName.weak50,
    radius: 54,
    pillRadius: 26,
    pillPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
    activeColor: ColorName.white,
    activeShadow: AppShadows.offerTabActive,
    textStyle: AppTextStyles.tab13,
    activeTextColor: ColorName.strong,
    inactiveTextColor: ColorName.soft,
    gap: 4,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PillTabs(
      tabs: [for (final value in OfferTab.values) (value, value.label(l10n))],
      selected: tab,
      onSelected: onTab,
      style: _style,
    );
  }
}
