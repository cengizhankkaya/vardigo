import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../tokens/app_dimens.dart';
import '../tokens/app_shadows.dart';
import 'app_icon.dart';

/// 44 × 44 white button with a border (back / help in the headers).
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final SvgGenImage icon;

  /// Read by screen readers.
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          width: AppSizes.squareButton,
          height: AppSizes.squareButton,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(AppRadius.squareButton),
            border: Border.all(color: ColorName.slate200),
            boxShadow: AppShadows.squareButton,
          ),
          child: AppIcon(icon, size: 20, color: ColorName.slate600),
        ),
      ),
    );
  }
}
