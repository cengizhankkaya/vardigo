import 'package:flutter/material.dart';

/// Case UI colours by role, for the parts [ColorScheme] has no slot for:
/// text levels, card and tab surfaces, borders. One instance per theme mode
/// lives in [AppPalette]; widgets read it with `context.appColors`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.card,
    required this.bar,
    required this.tabTrack,
    required this.tabTrackSoft,
    required this.tabPillActive,
    required this.fillMuted,
    required this.fillSubtle,
    required this.placeholder,
    required this.backdrop,
    required this.border,
    required this.stroke,
    required this.borderStrong,
    required this.textStrong,
    required this.textTitle,
    required this.textSecondary,
    required this.textCaption,
    required this.textHint,
    required this.textInactive,
    required this.textSoft,
    required this.icon,
    required this.accent,
  });

  /// Cards, chips and square buttons.
  final Color card;

  /// Bottom bar behind "Görüşme Talebi Gönder".
  final Color bar;

  /// Track behind the candidate tabs.
  final Color tabTrack;

  /// Track behind the offer tabs.
  final Color tabTrackSoft;

  /// Active pill on the offer tabs.
  final Color tabPillActive;

  /// Pay line inside a candidate card.
  final Color fillMuted;

  /// "Süresi doldu" label.
  final Color fillSubtle;

  /// Photo and logo before they load.
  final Color placeholder;

  /// Around the reference phone frame.
  final Color backdrop;

  /// Card borders and dividers.
  final Color border;

  /// Offer card border, bottom bar edge, outlined buttons.
  final Color stroke;

  /// Unchecked checkbox.
  final Color borderStrong;

  /// Tab labels, countdown, status bar time.
  final Color textStrong;

  /// Titles, names, metrics.
  final Color textTitle;

  /// Help, empty and error texts.
  final Color textSecondary;

  /// Business name, subtitles.
  final Color textCaption;

  /// "26 personel bulundu".
  final Color textHint;

  /// Inactive candidate tab, chevrons.
  final Color textInactive;

  /// Inactive offer tab.
  final Color textSoft;

  /// Icons on square buttons.
  final Color icon;

  /// Primary-coloured text and icons on a surface (not on a filled button).
  final Color accent;

  @override
  AppColors copyWith({
    Color? card,
    Color? bar,
    Color? tabTrack,
    Color? tabTrackSoft,
    Color? tabPillActive,
    Color? fillMuted,
    Color? fillSubtle,
    Color? placeholder,
    Color? backdrop,
    Color? border,
    Color? stroke,
    Color? borderStrong,
    Color? textStrong,
    Color? textTitle,
    Color? textSecondary,
    Color? textCaption,
    Color? textHint,
    Color? textInactive,
    Color? textSoft,
    Color? icon,
    Color? accent,
  }) => AppColors(
    card: card ?? this.card,
    bar: bar ?? this.bar,
    tabTrack: tabTrack ?? this.tabTrack,
    tabTrackSoft: tabTrackSoft ?? this.tabTrackSoft,
    tabPillActive: tabPillActive ?? this.tabPillActive,
    fillMuted: fillMuted ?? this.fillMuted,
    fillSubtle: fillSubtle ?? this.fillSubtle,
    placeholder: placeholder ?? this.placeholder,
    backdrop: backdrop ?? this.backdrop,
    border: border ?? this.border,
    stroke: stroke ?? this.stroke,
    borderStrong: borderStrong ?? this.borderStrong,
    textStrong: textStrong ?? this.textStrong,
    textTitle: textTitle ?? this.textTitle,
    textSecondary: textSecondary ?? this.textSecondary,
    textCaption: textCaption ?? this.textCaption,
    textHint: textHint ?? this.textHint,
    textInactive: textInactive ?? this.textInactive,
    textSoft: textSoft ?? this.textSoft,
    icon: icon ?? this.icon,
    accent: accent ?? this.accent,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      card: mix(card, other.card),
      bar: mix(bar, other.bar),
      tabTrack: mix(tabTrack, other.tabTrack),
      tabTrackSoft: mix(tabTrackSoft, other.tabTrackSoft),
      tabPillActive: mix(tabPillActive, other.tabPillActive),
      fillMuted: mix(fillMuted, other.fillMuted),
      fillSubtle: mix(fillSubtle, other.fillSubtle),
      placeholder: mix(placeholder, other.placeholder),
      backdrop: mix(backdrop, other.backdrop),
      border: mix(border, other.border),
      stroke: mix(stroke, other.stroke),
      borderStrong: mix(borderStrong, other.borderStrong),
      textStrong: mix(textStrong, other.textStrong),
      textTitle: mix(textTitle, other.textTitle),
      textSecondary: mix(textSecondary, other.textSecondary),
      textCaption: mix(textCaption, other.textCaption),
      textHint: mix(textHint, other.textHint),
      textInactive: mix(textInactive, other.textInactive),
      textSoft: mix(textSoft, other.textSoft),
      icon: mix(icon, other.icon),
      accent: mix(accent, other.accent),
    );
  }
}
