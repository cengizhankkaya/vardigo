import 'package:flutter/material.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/tokens/app_text_styles.dart';

/// Bottom sheet behind the "?" button: what the tabs and selection mean.
Future<void> showCandidatesHelp(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ColorName.white,
      builder: (_) => const _CandidatesHelp(),
    );

class _CandidatesHelp extends StatelessWidget {
  const _CandidatesHelp();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.helpTitle, style: AppTextStyles.title18),
          const SizedBox(height: 8),
          Text(
            context.l10n.candidatesHelp,
            style: AppTextStyles.label14.copyWith(
              color: ColorName.sub,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
