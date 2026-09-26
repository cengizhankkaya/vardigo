import 'package:flutter/painting.dart';

import '../../../gen/fonts.gen.dart';

/// Case typography (specs/00-design-tokens.txt): size / weight / line height
/// and letter spacing. Colours come from the theme: widgets use the coloured
/// copies in `context.textStyles` (see AppTextTheme), not these directly.
abstract final class AppTextStyles {
  /// The case asks for `liga` and `calt` off on every text.
  static const noLigatures = [
    FontFeature.disable('liga'),
    FontFeature.disable('calt'),
  ];

  /// "9:41" in the reference phone frame. 17 / 700 / 22, -0.3.
  static const statusTime = _Style(17, FontWeight.w700, 22, -0.3);

  /// "Görüşme Talepleri". 20 / 600 / 28.
  static const title20 = _Style(20, FontWeight.w600, 28, 0);

  /// Candidate name, job title. 18 / 500 / 24, -0.27.
  static const title18 = _Style(18, FontWeight.w500, 24, -0.27);

  /// "Eşleşen Personeller". 16 / 500 / 24, -0.176.
  static const title16Medium = _Style(16, FontWeight.w500, 24, -0.176);

  /// "1 kişi seçildi", pay "45.000". 16 / 600 / 24, -0.176.
  static const title16Semibold = _Style(16, FontWeight.w600, 24, -0.176);

  /// "26 personel bulundu". 13 / 400 / 20, -0.078.
  static const caption13 = _Style(13, FontWeight.w400, 20, -0.078);

  /// Rating, attendance, distance. 12 / 500 / 16.
  static const caption12Medium = _Style(12, FontWeight.w500, 16, 0);

  /// Business name, "12 talep yanıt bekliyor". 12 / 400 / 16.
  static const caption12 = _Style(12, FontWeight.w400, 16, 0);

  /// Buttons and chips. 14 / 500 / 20, -0.084.
  static const label14 = _Style(14, FontWeight.w500, 20, -0.084);

  /// Tab labels. 13 / 500, -0.084; the pill sets the height.
  static const tab13 = _Style(13, FontWeight.w500, null, -0.084);
}

/// A [TextStyle] in Urbanist with ligatures off, built from pixel values.
class _Style extends TextStyle {
  const _Style(
    double size,
    FontWeight weight,
    double? lineHeight,
    double tracking,
  ) : super(
        fontFamily: FontFamily.urbanist,
        fontSize: size,
        fontWeight: weight,
        height: lineHeight == null ? null : lineHeight / size,
        leadingDistribution: TextLeadingDistribution.even,
        letterSpacing: tracking,
        fontFeatures: AppTextStyles.noLigatures,
      );
}
