import 'package:flutter/material.dart';

import '../../../gen/assets.gen.dart';
import '../../theme/theme.dart';
import '../../theme/tokens/app_dimens.dart';
import 'app_icon.dart';

/// Square check mark; only draws the state, the parent handles taps.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.of(context);
    final colors = context.appColors;
    return Container(
      width: AppSizes.checkbox,
      height: AppSizes.checkbox,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? scheme.primary : colors.card,
        borderRadius: BorderRadius.circular(AppRadius.checkbox),
        border: Border.all(
          color: selected ? scheme.primary : colors.borderStrong,
        ),
      ),
      child: selected
          ? AppIcon(Assets.icons.check, size: 14, color: scheme.onPrimary)
          : null,
    );
  }
}
