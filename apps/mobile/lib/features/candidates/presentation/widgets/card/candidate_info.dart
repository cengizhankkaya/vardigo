import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/app_icon.dart';
import '../../../../../core/presentation/widgets/inline_divider.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/theme/tokens/app_spacing.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../domain/entities/candidate.dart';

/// Name, then rating | attendance | distance.
class CandidateInfo extends StatelessWidget {
  const CandidateInfo(this.candidate, {super.key});

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          candidate.name,
          style: context.textStyles.title18,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            _Metric(
              AppIcon(Assets.icons.star, color: context.semanticColors.warning),
              candidate.rating,
            ),
            const InlineDivider(),
            _Metric(AppIcon(Assets.icons.shield), candidate.attendance),
            const InlineDivider(),
            _Metric(AppIcon(Assets.icons.pin, size: 14), candidate.distance),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.text);

  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: AppSpacing.iconText),
        Text(text, style: context.textStyles.caption12Medium),
      ],
    );
  }
}
