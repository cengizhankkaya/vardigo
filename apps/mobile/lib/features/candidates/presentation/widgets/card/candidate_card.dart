import 'package:flutter/material.dart';

import '../../../../../shared/design_system/components/app_checkbox.dart';
import '../../../../../shared/design_system/theme/theme.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../../shared/design_system/tokens/app_shadows.dart';
import '../../../domain/candidate.dart';
import 'candidate_avatar.dart';
import 'candidate_info.dart';
import 'pay_match_line.dart';

/// One candidate: photo, name, rating / attendance / distance, pay line and
/// a checkbox. The whole card toggles the selection.
class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    required this.selected,
    required this.onToggle,
  });

  final Candidate candidate;
  final bool selected;
  final VoidCallback? onToggle;

  static const _stripeWidth = 4.0;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final colors = context.appColors;
    return Semantics(
      checked: selected,
      label: candidate.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onToggle,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : colors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: selected ? null : Border.all(color: colors.border),
            boxShadow: selected ? AppShadows.cardSelected : AppShadows.card,
          ),
          // Selected cards have no border, so their content sits 1 px further
          // out; the padding keeps both states aligned.
          padding: EdgeInsets.all(selected ? 1 : 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card - 1),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
                  child: _Content(candidate: candidate, selected: selected),
                ),
                if (selected)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: _stripeWidth,
                    child: ColoredBox(color: scheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.candidate, required this.selected});

  final Candidate candidate;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final expectedPay = candidate.expectedPay;
    return Column(
      children: [
        Row(
          children: [
            CandidateAvatar(candidate),
            const SizedBox(width: AppSpacing.cardPhotoText),
            Expanded(child: CandidateInfo(candidate)),
            const SizedBox(width: 8),
            AppCheckbox(selected: selected),
          ],
        ),
        if (expectedPay != null) ...[
          const SizedBox(height: 12),
          PayMatchLine(
            expectedPay: expectedPay,
            fits: candidate.payCompatible ?? false,
          ),
        ],
      ],
    );
  }
}
