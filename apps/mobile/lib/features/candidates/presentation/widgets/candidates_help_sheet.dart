import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../../shared/design_system/theme/theme.dart';

/// Bottom sheet behind the "?" button: what the tabs and selection mean.
Future<void> showCandidatesHelp(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.appColors.card,
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
          Text(context.l10n.helpTitle, style: context.textStyles.title18),
          const SizedBox(height: 8),
          Text(
            context.l10n.candidatesHelp,
            style: context.textStyles.label14.copyWith(
              color: context.appColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
