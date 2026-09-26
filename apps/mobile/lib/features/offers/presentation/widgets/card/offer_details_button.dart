import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/presentation/widgets/action_button.dart';
import '../../../../../core/theme/theme.dart';
import '../../../../../gen/assets.gen.dart';

/// "Detayları Gör" / "Detayları Gizle".
class OfferDetailsButton extends StatelessWidget {
  const OfferDetailsButton({
    super.key,
    required this.expanded,
    required this.onTap,
  });

  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ActionButton(
      icon: Assets.icons.eye,
      label: expanded ? l10n.hideDetails : l10n.viewDetails,
      foreground: context.appColors.textSecondary,
      border: context.appColors.stroke,
      onTap: onTap,
    );
  }
}
