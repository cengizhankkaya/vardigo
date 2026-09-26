import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/gen/colors.gen.dart';
import 'package:vardigo/gen/fonts.gen.dart';
import 'package:vardigo/shared/design_system/theme/app_theme.dart';
import 'package:vardigo/shared/design_system/tokens/app_text_styles.dart';

void main() {
  final theme = AppTheme.light();

  test('default text is Urbanist without ligatures', () {
    for (final style in [
      theme.textTheme.bodyMedium!,
      theme.textTheme.titleLarge!,
      theme.textTheme.labelLarge!,
    ]) {
      expect(style.fontFamily, FontFamily.urbanist);
      expect(style.fontFeatures, AppTextStyles.noLigatures);
    }
  });

  test('uses case colours and no ripple', () {
    expect(theme.colorScheme.primary, ColorName.primary);
    expect(theme.colorScheme.error, ColorName.error);
    expect(theme.scaffoldBackgroundColor, ColorName.white);
    expect(theme.splashFactory, NoSplash.splashFactory);
  });
}
