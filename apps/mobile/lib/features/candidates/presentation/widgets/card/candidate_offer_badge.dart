import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/theme/tokens/app_radius.dart';
import '../../../../../core/theme/tokens/app_spacing.dart';
import '../../../domain/entities/candidate_offer_status.dart';

/// What the job seeker did with the newest request: waiting, accepted,
/// rejected or ran out. Same colours as the job seeker's own status label.
class CandidateOfferBadge extends StatelessWidget {
  const CandidateOfferBadge(this.status, {super.key});

  final CandidateOfferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = ColorScheme.of(context);
    final semantic = context.semanticColors;
    final colors = context.appColors;
    final (text, icon, color, background) = switch (status) {
      CandidateOfferStatus.pending => (
        l10n.candidateOfferPending,
        Icons.schedule_rounded,
        scheme.onPrimaryContainer,
        scheme.primaryContainer,
      ),
      CandidateOfferStatus.accepted => (
        l10n.candidateOfferAccepted,
        Icons.check_circle_rounded,
        semantic.onSuccessContainer,
        semantic.successContainer,
      ),
      CandidateOfferStatus.rejected => (
        l10n.candidateOfferRejected,
        Icons.cancel_rounded,
        scheme.onErrorContainer,
        scheme.errorContainer,
      ),
      CandidateOfferStatus.expired => (
        l10n.candidateOfferExpired,
        Icons.timer_off_rounded,
        colors.textSecondary,
        colors.fillSubtle,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.iconText),
          Flexible(
            child: Text(
              text,
              style: context.textStyles.caption12Medium.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
