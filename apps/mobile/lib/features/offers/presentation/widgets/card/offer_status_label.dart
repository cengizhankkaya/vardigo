import 'package:flutter/material.dart';

import '../../../../../gen/colors.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../../shared/design_system/tokens/app_text_styles.dart';
import '../../../domain/offer.dart';

/// "İlgileniyorsun" / "İlgilenmiyorsun" / "Süresi doldu" in place of the
/// buttons.
class OfferStatusLabel extends StatelessWidget {
  const OfferStatusLabel(this.status, {super.key});

  final OfferStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (text, color, background) = switch (status) {
      OfferStatus.accepted => (
        l10n.statusAccepted,
        ColorName.greenDark,
        ColorName.greenLighter,
      ),
      OfferStatus.rejected => (
        l10n.statusRejected,
        ColorName.error,
        ColorName.errorSoft,
      ),
      _ => (l10n.statusExpired, ColorName.sub, ColorName.weak50),
    };
    return Container(
      height: AppSizes.actionButton,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.actionButton),
      ),
      child: Text(text, style: AppTextStyles.label14.copyWith(color: color)),
    );
  }
}
