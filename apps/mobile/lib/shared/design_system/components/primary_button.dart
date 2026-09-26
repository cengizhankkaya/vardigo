import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../tokens/app_dimens.dart';
import '../tokens/app_text_styles.dart';
import 'app_icon.dart';

/// Full-width blue call to action (44 high, radius 10). Disabled at 45%
/// opacity; shows a spinner while [loading].
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
    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: onPressed == null ? 0.45 : 1,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onPressed : null,
          child: Container(
            height: AppSizes.cta,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ColorName.primary,
              borderRadius: BorderRadius.circular(AppRadius.cta),
            ),
            child: loading
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ColorName.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        AppIcon(icon, size: 20, color: ColorName.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.label14.copyWith(
                          color: ColorName.white,
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
