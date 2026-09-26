import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../gen/colors.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../shared/design_system/components/action_button.dart';

/// "İlgilenmiyorum" and "İlgileniyorum"; both dimmed while [busy].
class OfferAnswerButtons extends StatelessWidget {
  const OfferAnswerButtons({
    super.key,
    required this.busy,
    required this.onAccept,
    required this.onReject,
  });

  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            icon: Assets.icons.close,
            label: l10n.notInterested,
            foreground: ColorName.error,
            background: ColorName.errorSoft,
            onTap: busy ? null : onReject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            icon: Assets.icons.check,
            label: l10n.interested,
            foreground: ColorName.white,
            background: ColorName.green,
            onTap: busy ? null : onAccept,
          ),
        ),
      ],
    );
  }
}
