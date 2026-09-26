import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/square_icon_button.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_spacing.dart';
import '../../../../gen/assets.gen.dart';
import '../../domain/entities/candidate_tab.dart';
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
          onPressed: () => context.pop(),
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
