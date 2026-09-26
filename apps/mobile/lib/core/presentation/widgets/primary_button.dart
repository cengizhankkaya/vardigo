import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../theme/theme.dart';
import '../../theme/tokens/app_radius.dart';
import '../../theme/tokens/app_sizes.dart';
import 'app_icon.dart';

/// Full-width blue call to action (44 high, radius 10). Disabled at 45%
/// opacity; shows a spinner while [loading]. Under large system text the
/// label wraps and the button grows taller.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  final String label;
  final SvgGenImage? icon;

  /// Null disables the button.
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final icon = this.icon;
    final scheme = ColorScheme.of(context);
    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onPressed : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: AppSizes.cta),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.cta),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: loading
                  ? [
                      SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ]
                  : [
                      if (icon != null) ...[
                        AppIcon(icon, size: 20, color: scheme.onPrimary),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: context.textStyles.label14.copyWith(
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
