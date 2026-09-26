import 'package:flutter/material.dart';

import '../../../../../gen/assets.gen.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../shared/design_system/components/action_button.dart';
import '../../../../../shared/design_system/theme/theme.dart';

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
    final scheme = ColorScheme.of(context);
    final semantic = context.semanticColors;
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            icon: Assets.icons.close,
            label: l10n.notInterested,
            foreground: scheme.onErrorContainer,
            background: scheme.errorContainer,
            onTap: busy ? null : onReject,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            icon: Assets.icons.check,
            label: l10n.interested,
            foreground: semantic.onSuccess,
            background: semantic.success,
            onTap: busy ? null : onAccept,
          ),
        ),
      ],
    );
  }
}
