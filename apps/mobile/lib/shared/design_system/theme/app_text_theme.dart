import 'package:flutter/material.dart';

import '../tokens/app_text_styles.dart';
import 'app_colors.dart';

/// The case's 10 text styles with this theme's default colours. Widgets read
/// them with `context.textStyles.title18` and change only the colour with
/// `copyWith(color: ...)`.
@immutable
class AppTextTheme extends ThemeExtension<AppTextTheme> {
  const AppTextTheme({
    required this.statusTime,
    required this.title20,
    required this.title18,
    required this.title16Medium,
    required this.title16Semibold,
    required this.caption13,
    required this.caption12Medium,
    required this.caption12,
    required this.label14,
    required this.tab13,
  });

  /// Case sizes from [AppTextStyles] with the colours of [colors].
  factory AppTextTheme.from(AppColors colors) => AppTextTheme(
    statusTime: AppTextStyles.statusTime.copyWith(color: colors.textStrong),
    title20: AppTextStyles.title20.copyWith(color: colors.textTitle),
    title18: AppTextStyles.title18.copyWith(color: colors.textTitle),
    title16Medium: AppTextStyles.title16Medium.copyWith(
      color: colors.textTitle,
    ),
    title16Semibold: AppTextStyles.title16Semibold.copyWith(
      color: colors.accent,
    ),
    caption13: AppTextStyles.caption13.copyWith(color: colors.textHint),
    caption12Medium: AppTextStyles.caption12Medium.copyWith(
      color: colors.textTitle,
    ),
    caption12: AppTextStyles.caption12.copyWith(color: colors.textCaption),
    label14: AppTextStyles.label14.copyWith(color: colors.accent),
    tab13: AppTextStyles.tab13.copyWith(color: colors.textStrong),
  );

  final TextStyle statusTime;
  final TextStyle title20;
  final TextStyle title18;
  final TextStyle title16Medium;
  final TextStyle title16Semibold;
  final TextStyle caption13;
  final TextStyle caption12Medium;
  final TextStyle caption12;
  final TextStyle label14;
  final TextStyle tab13;

  @override
  AppTextTheme copyWith({
    TextStyle? statusTime,
    TextStyle? title20,
    TextStyle? title18,
    TextStyle? title16Medium,
    TextStyle? title16Semibold,
    TextStyle? caption13,
    TextStyle? caption12Medium,
    TextStyle? caption12,
    TextStyle? label14,
    TextStyle? tab13,
  }) => AppTextTheme(
    statusTime: statusTime ?? this.statusTime,
    title20: title20 ?? this.title20,
    title18: title18 ?? this.title18,
    title16Medium: title16Medium ?? this.title16Medium,
    title16Semibold: title16Semibold ?? this.title16Semibold,
    caption13: caption13 ?? this.caption13,
    caption12Medium: caption12Medium ?? this.caption12Medium,
    caption12: caption12 ?? this.caption12,
    label14: label14 ?? this.label14,
    tab13: tab13 ?? this.tab13,
  );

  @override
  AppTextTheme lerp(AppTextTheme? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTextTheme(
      statusTime: mix(statusTime, other.statusTime),
      title20: mix(title20, other.title20),
      title18: mix(title18, other.title18),
      title16Medium: mix(title16Medium, other.title16Medium),
      title16Semibold: mix(title16Semibold, other.title16Semibold),
      caption13: mix(caption13, other.caption13),
      caption12Medium: mix(caption12Medium, other.caption12Medium),
      caption12: mix(caption12, other.caption12),
      label14: mix(label14, other.label14),
      tab13: mix(tab13, other.tab13),
    );
  }
}
