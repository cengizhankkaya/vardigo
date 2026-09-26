import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/colors.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../shared/design_system/components/app_icon.dart';
import '../../../../../shared/design_system/tokens/app_dimens.dart';
import '../../../../../shared/design_system/tokens/app_text_styles.dart';

/// "Ücret beklentisi uyuşuyor · ₺25.000 / ay"; green when it fits, amber
/// when it does not.
class PayMatchLine extends StatelessWidget {
  const PayMatchLine({
    super.key,
    required this.expectedPay,
    required this.fits,
  });

  final String expectedPay;
  final bool fits;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = fits ? ColorName.green : ColorName.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: ColorName.slate50,
        borderRadius: BorderRadius.circular(AppRadius.actionButton),
      ),
      child: Row(
        children: [
          AppIcon(Assets.icons.money, color: color),
          const SizedBox(width: AppSpacing.iconText),
          Expanded(
            child: Text(
              fits ? l10n.payMatches : l10n.payMismatch,
              style: AppTextStyles.caption12Medium.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            l10n.payPerMonth(expectedPay),
            style: AppTextStyles.caption12Medium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
