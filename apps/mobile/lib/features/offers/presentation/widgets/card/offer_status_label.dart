import 'package:flutter/material.dart';

import '../../../../../l10n/l10n.dart';
import '../../../../../shared/design_system/theme/theme.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../domain/offer.dart';

/// "İlgileniyorsun" / "İlgilenmiyorsun" / "Süresi doldu" in place of the
/// buttons.
class OfferStatusLabel extends StatelessWidget {
  const OfferStatusLabel(this.status, {super.key});

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = ColorScheme.of(context);
    final semantic = context.semanticColors;
    final colors = context.appColors;
    final (text, color, background) = switch (status) {
      OfferStatus.accepted => (
        l10n.statusAccepted,
        semantic.onSuccessContainer,
        semantic.successContainer,
      ),
      OfferStatus.rejected => (
        l10n.statusRejected,
        scheme.onErrorContainer,
        scheme.errorContainer,
      ),
      _ => (l10n.statusExpired, colors.textSecondary, colors.fillSubtle),
    };
    return Container(
      height: AppSizes.actionButton,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.actionButton),
      ),
      child: Text(
        text,
        style: context.textStyles.label14.copyWith(color: color),
      ),
    );
  }
}
