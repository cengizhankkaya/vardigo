import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_theme.dart';
import 'semantic_colors.dart';

/// Theme extensions of the current theme:
///
/// ```dart
/// final colors = context.appColors;         // text levels, surfaces, borders
/// final semantic = context.semanticColors;  // success, warning, info
/// final text = context.textStyles;          // case text styles
/// final scheme = ColorScheme.of(context);   // primary, error, surface
/// ```
extension ThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
  SemanticColors get semanticColors =>
      Theme.of(this).extension<SemanticColors>()!;
  AppTextTheme get textStyles => Theme.of(this).extension<AppTextTheme>()!;
}
