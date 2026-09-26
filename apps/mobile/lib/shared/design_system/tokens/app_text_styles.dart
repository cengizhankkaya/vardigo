import 'package:flutter/painting.dart';

import '../../../gen/colors.gen.dart';
import '../../../gen/fonts.gen.dart';

/// Case typography (specs/00-design-tokens.txt): size / weight / line height,
/// letter spacing and default colour. Screens change only the colour with
/// `copyWith(color: ...)`.
abstract final class AppTextStyles {
  /// The case asks for `liga` and `calt` off on every text.
  static const noLigatures = [
    FontFeature.disable('liga'),
    FontFeature.disable('calt'),
  ];

  /// "9:41" in the reference phone frame. 17 / 700 / 22, -0.3.
  static const statusTime = _Style(
    17,
    FontWeight.w700,
    22,
    -0.3,
    ColorName.strong,
  );

  /// "Görüşme Talepleri". 20 / 600 / 28.
  static const title20 = _Style(20, FontWeight.w600, 28, 0, ColorName.slate700);

  /// Candidate name, job title. 18 / 500 / 24, -0.27.
  static const title18 = _Style(
    18,
    FontWeight.w500,
    24,
    -0.27,
    ColorName.slate700,
  );

  /// "Eşleşen Personeller". 16 / 500 / 24, -0.176.
  static const title16Medium = _Style(
    16,
    FontWeight.w500,
    24,
    -0.176,
    ColorName.slate700,
  );

  /// "1 kişi seçildi", pay "45.000". 16 / 600 / 24, -0.176.
  static const title16Semibold = _Style(
    16,
    FontWeight.w600,
    24,
    -0.176,
    ColorName.primary,
  );

  /// "26 personel bulundu". 13 / 400 / 20, -0.078, slate-500 at 80%.
  static const caption13 = _Style(
    13,
    FontWeight.w400,
    20,
    -0.078,
    Color(0xCC717784),
  );

  /// Rating, attendance, distance. 12 / 500 / 16.
  static const caption12Medium = _Style(
    12,
    FontWeight.w500,
    16,
    0,
    ColorName.slate700,
  );

  /// Business name, "12 talep yanıt bekliyor". 12 / 400 / 16.
  static const caption12 = _Style(
    12,
    FontWeight.w400,
    16,
    0,
    ColorName.gray500,
  );

  /// Buttons and chips. 14 / 500 / 20, -0.084.
  static const label14 = _Style(
    14,
    FontWeight.w500,
    20,
    -0.084,
    ColorName.primary,
  );

  /// Tab labels. 13 / 500, -0.084; the pill sets the height.
  static const tab13 = _Style(
    13,
    FontWeight.w500,
    null,
    -0.084,
    ColorName.strong,
  );
}

/// A [TextStyle] in Urbanist with ligatures off, built from pixel values.
class _Style extends TextStyle {
  const _Style(
    double size,
    FontWeight weight,
    double? lineHeight,
    double tracking,
    Color color,
  ) : super(
        fontFamily: FontFamily.urbanist,
        fontSize: size,
        fontWeight: weight,
        height: lineHeight == null ? null : lineHeight / size,
        leadingDistribution: TextLeadingDistribution.even,
        letterSpacing: tracking,
        color: color,
        fontFeatures: AppTextStyles.noLigatures,
      );
}
