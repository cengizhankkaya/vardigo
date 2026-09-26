import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/gen/colors.gen.dart';
import 'package:vardigo/gen/fonts.gen.dart';
import 'package:vardigo/shared/design_system/tokens/app_text_styles.dart';

void main() {
  test('line height is converted from pixels to a multiplier', () {
    // 18 / 500 / 24 → height 24 / 18.
    const style = AppTextStyles.title18;
    expect(style.fontSize, 18);
    expect(style.fontWeight, FontWeight.w500);
    expect(style.fontSize! * style.height!, closeTo(24, 0.001));
    expect(style.letterSpacing, -0.27);
    expect(style.color, ColorName.slate700);
  });

  test('every style uses Urbanist without ligatures', () {
    const styles = [
      AppTextStyles.statusTime,
      AppTextStyles.title20,
      AppTextStyles.title18,
      AppTextStyles.title16Medium,
      AppTextStyles.title16Semibold,
      AppTextStyles.caption13,
      AppTextStyles.caption12Medium,
      AppTextStyles.caption12,
      AppTextStyles.label14,
      AppTextStyles.tab13,
    ];
    for (final style in styles) {
      expect(style.fontFamily, FontFamily.urbanist);
      expect(
        style.fontFeatures,
        containsAll(const [
          FontFeature.disable('liga'),
          FontFeature.disable('calt'),
        ]),
      );
    }
  });

  test('caption13 is slate-500 at 80%', () {
    expect(
      AppTextStyles.caption13.color,
      ColorName.slate500.withValues(alpha: 0.8),
    );
  });
}
