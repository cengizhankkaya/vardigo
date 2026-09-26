import 'package:flutter/material.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../shared/design_system/components/pill_tabs.dart';
import '../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';
import '../../domain/candidate.dart';

/// "%100 Eşleşme (26)" / "Benzer Personeller (16)".
class CandidateTabs extends StatelessWidget {
  const CandidateTabs({
    super.key,
    required this.tab,
    required this.perfectLabel,
    required this.similarLabel,
    required this.onTab,
  });

  final CandidateTab tab;
  final String perfectLabel;
  final String similarLabel;
  final ValueChanged<CandidateTab> onTab;

  static const _style = PillTabsStyle(
    background: ColorName.slate100,
    radius: AppRadius.pill,
    pillRadius: AppRadius.pill,
    pillPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    activeColor: ColorName.primary,
    activeShadow: AppShadows.candidateTabActive,
    textStyle: AppTextStyles.caption12Medium,
    activeTextColor: ColorName.white,
    inactiveTextColor: ColorName.slate500,
  );

  @override
  Widget build(BuildContext context) {
    return PillTabs(
      tabs: [
        (CandidateTab.perfect, perfectLabel),
        (CandidateTab.similar, similarLabel),
      ],
      selected: tab,
      onSelected: onTab,
      style: _style,
    );
  }
}
