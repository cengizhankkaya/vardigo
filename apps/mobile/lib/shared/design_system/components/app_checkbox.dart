import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../tokens/app_dimens.dart';
import 'app_icon.dart';

/// Square check mark; only draws the state, the parent handles taps.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? ColorName.primary : ColorName.white,
        borderRadius: BorderRadius.circular(AppRadius.checkbox),
        border: Border.all(
          color: selected ? ColorName.primary : ColorName.slate300,
        ),
      ),
      child: selected
          ? AppIcon(Assets.icons.check, size: 14, color: ColorName.white)
          : null,
    );
  }
}
