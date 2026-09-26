import 'package:flutter/material.dart';

import '../../../gen/colors.gen.dart';
import '../../../gen/fonts.gen.dart';
import '../tokens/app_text_styles.dart';

abstract final class AppTheme {
  /// Urbanist everywhere with ligatures off, case colours, and no Material
  /// ripple (the reference design has none).
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: FontFamily.urbanist,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ColorName.primary,
        primary: ColorName.primary,
        error: ColorName.error,
        surface: ColorName.white,
        onSurface: ColorName.strong,
      ),
      scaffoldBackgroundColor: ColorName.white,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
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
