import 'package:flutter/material.dart';

import '../../gen/fonts.gen.dart';
import 'tokens/app_text_styles.dart';
import 'app_colors.dart';
import 'app_palette.dart';
import 'app_text_theme.dart';
import 'semantic_colors.dart';

/// Light (the reference design) and dark themes. Both use Urbanist with
/// ligatures off, only case colours, and no Material ripple.
abstract final class AppTheme {
  static ThemeData light() => _build(
    AppPalette.lightScheme,
    AppPalette.lightColors,
    AppPalette.lightSemantic,
  );

  static ThemeData dark() => _build(
    AppPalette.darkScheme,
    AppPalette.darkColors,
    AppPalette.darkSemantic,
  );

  static ThemeData _build(
    ColorScheme scheme,
    AppColors colors,
    SemanticColors semantic,
  ) {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: FontFamily.urbanist,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [colors, semantic, AppTextTheme.from(colors)],
    );
    const noLigatures = TextStyle(fontFeatures: AppTextStyles.noLigatures);
    return base.copyWith(
      textTheme: base.textTheme.merge(
        const TextTheme(
          displayLarge: noLigatures,
          displayMedium: noLigatures,
          displaySmall: noLigatures,
          headlineLarge: noLigatures,
          headlineMedium: noLigatures,
          headlineSmall: noLigatures,
          titleLarge: noLigatures,
          titleMedium: noLigatures,
          titleSmall: noLigatures,
          bodyLarge: noLigatures,
          bodyMedium: noLigatures,
          bodySmall: noLigatures,
          labelLarge: noLigatures,
          labelMedium: noLigatures,
          labelSmall: noLigatures,
        ),
      ),
    );
  }
}
