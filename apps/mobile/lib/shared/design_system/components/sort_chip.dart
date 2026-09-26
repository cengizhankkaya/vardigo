import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../tokens/app_dimens.dart';
import '../tokens/app_shadows.dart';
import '../tokens/app_text_styles.dart';
import 'app_icon.dart';

/// "Sırala: Önerilen" chip; each tap moves to the next sort option.
class SortChip extends StatelessWidget {
  const SortChip({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: ColorName.white,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: ColorName.slate200),
            boxShadow: AppShadows.chip,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppIcon(Assets.icons.sort, size: 20, color: ColorName.primary),
              const SizedBox(width: 2),
              Text(label, style: AppTextStyles.label14),
            ],
          ),
        ),
      ),
    );
  }
}
