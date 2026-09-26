import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/presentation/widgets/app_icon.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../core/theme/tokens/app_dimens.dart';

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
    final semantic = context.semanticColors;
    final color = fits ? semantic.success : semantic.warning;
    final style = context.textStyles.caption12Medium.copyWith(color: color);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.fillMuted,
        borderRadius: BorderRadius.circular(AppRadius.actionButton),
      ),
      child: Row(
        children: [
          AppIcon(Assets.icons.money, color: color),
          const SizedBox(width: AppSpacing.iconText),
          Expanded(
            child: Text(
              fits ? l10n.payMatches : l10n.payMismatch,
              style: style,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            l10n.payPerMonth(expectedPay),
            style: style.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
