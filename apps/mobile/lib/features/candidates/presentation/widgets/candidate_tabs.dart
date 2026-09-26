import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/pill_tabs.dart';
import '../../../../core/presentation/widgets/pill_tabs_style.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/theme/tokens/app_shadows.dart';
import '../../domain/entities/candidate_tab.dart';

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

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final colors = context.appColors;
    return PillTabs(
      tabs: [
        (CandidateTab.perfect, perfectLabel),
        (CandidateTab.similar, similarLabel),
      ],
      selected: tab,
      onSelected: onTab,
      style: PillTabsStyle(
        background: colors.tabTrack,
        radius: AppRadius.pill,
        pillRadius: AppRadius.pill,
        pillPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        activeColor: scheme.primary,
        activeShadow: AppShadows.candidateTabActive,
        textStyle: context.textStyles.caption12Medium,
        activeTextColor: scheme.onPrimary,
        inactiveTextColor: colors.textInactive,
      ),
    );
  }
}
