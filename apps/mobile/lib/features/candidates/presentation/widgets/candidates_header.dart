import 'package:flutter/material.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/components/square_icon_button.dart';
import '../../../../shared/design_system/theme/theme.dart';
import '../../../../shared/design_system/tokens/app_dimens.dart';
import '../../domain/candidate.dart';
import 'candidate_tabs.dart';
import 'candidates_help_sheet.dart';

/// Back button, "26 personel bulundu / Eşleşen Personeller", help button and
/// the tabs. Totals are null until the first list arrives.
class CandidatesHeader extends StatelessWidget {
  const CandidatesHeader({
    super.key,
    required this.totalPerfect,
    required this.totalSimilar,
    required this.tab,
    required this.onTab,
  });

  final int? totalPerfect;
  final int? totalSimilar;
  final CandidateTab tab;
  final ValueChanged<CandidateTab> onTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        16,
        AppSpacing.page,
        8,
      ),
      child: Column(
        children: [
          _TitleRow(
            total: tab == CandidateTab.perfect ? totalPerfect : totalSimilar,
          ),
          const SizedBox(height: 20),
          CandidateTabs(
            tab: tab,
            perfectLabel: l10n.tabPerfect(totalPerfect ?? 0),
            similarLabel: l10n.tabSimilar(totalSimilar ?? 0),
            onTab: onTab,
          ),
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({required this.total});

  /// Count of the active tab.
  final int? total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = this.total;
    return Row(
      children: [
        SquareIconButton(
          icon: Assets.icons.back,
          label: l10n.back,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                total == null ? '' : l10n.candidatesFound(total),
                style: context.textStyles.caption13,
              ),
              Text(
                l10n.candidatesTitle,
                style: context.textStyles.title16Medium,
              ),
            ],
          ),
        ),
        SquareIconButton(
          icon: Assets.icons.help,
          label: l10n.help,
          onPressed: () => showCandidatesHelp(context),
        ),
      ],
    );
  }
}
