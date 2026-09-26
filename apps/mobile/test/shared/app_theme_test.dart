import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/core/theme/theme.dart';
import 'package:vardigo/core/theme/tokens/app_text_styles.dart';
import 'package:vardigo/gen/colors.gen.dart';
import 'package:vardigo/gen/fonts.gen.dart';

/// Every colour in assets/colors/colors.xml, the case palette.
Set<Color> _casePalette() {
  final xml = File('assets/colors/colors.xml').readAsStringSync();
  return RegExp(r'#([0-9A-Fa-f]{6,8})<').allMatches(xml).map((m) {
    final hex = m.group(1)!;
    return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
  }).toSet();
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (la > lb ? la + 0.05 : lb + 0.05) / (la > lb ? lb + 0.05 : la + 0.05);
}

void main() {
  final light = AppTheme.light();
  final dark = AppTheme.dark();

  test('default text is Urbanist without ligatures', () {
    for (final theme in [light, dark]) {
      for (final style in [
        theme.textTheme.bodyMedium!,
        theme.textTheme.titleLarge!,
        theme.textTheme.labelLarge!,
      ]) {
        expect(style.fontFamily, FontFamily.urbanist);
        expect(style.fontFeatures, AppTextStyles.noLigatures);
      }
    }
  });

  test('light is the reference design and has no ripple', () {
    expect(light.brightness, Brightness.light);
    expect(light.colorScheme.primary, ColorName.primary);
    expect(light.colorScheme.error, ColorName.error);
    expect(light.scaffoldBackgroundColor, ColorName.white);
    expect(light.splashFactory, NoSplash.splashFactory);

    final text = light.extension<AppTextTheme>()!;
    expect(text.title18.color, ColorName.slate700);
    expect(text.title18.fontSize, 18);
    expect(text.caption13.color, ColorName.slate500.withValues(alpha: 0.8));
    expect(text.label14.color, ColorName.primary);
  });

  test('dark theme has its own surfaces and the same extensions', () {
    expect(dark.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor, ColorName.strong);
    expect(dark.splashFactory, NoSplash.splashFactory);
    expect(dark.extension<AppColors>(), AppPalette.darkColors);
    expect(dark.extension<SemanticColors>(), AppPalette.darkSemantic);
    expect(dark.extension<AppTextTheme>()!.title18.color, ColorName.white);
  });

  test('both themes use only case palette colours', () {
    final palette = _casePalette();
    // The case gives this one as slate-500 at 80% rather than as a token.
    final allowed = {...palette, ColorName.slate500.withValues(alpha: 0.8)};
    final darkOnly = {AppPalette.errorOnDark};
    for (final (name, colors, semantic, scheme) in [
      (
        'light',
        AppPalette.lightColors,
        AppPalette.lightSemantic,
        AppPalette.lightScheme,
      ),
      (
        'dark',
        AppPalette.darkColors,
        AppPalette.darkSemantic,
        AppPalette.darkScheme,
      ),
    ]) {
      final used = [
        colors.card,
        colors.bar,
        colors.tabTrack,
        colors.tabTrackSoft,
        colors.tabPillActive,
        colors.fillMuted,
        colors.fillSubtle,
        colors.placeholder,
        colors.backdrop,
        colors.border,
        colors.stroke,
        colors.borderStrong,
        colors.textStrong,
        colors.textTitle,
        colors.textSecondary,
        colors.textCaption,
        colors.textHint,
        colors.textInactive,
        colors.textSoft,
        colors.icon,
        colors.accent,
        semantic.success,
        semantic.onSuccess,
        semantic.successContainer,
        semantic.onSuccessContainer,
        semantic.warning,
        semantic.info,
        scheme.primary,
        scheme.onPrimary,
        scheme.primaryContainer,
        scheme.onPrimaryContainer,
        scheme.error,
        scheme.onError,
        scheme.errorContainer,
        scheme.onErrorContainer,
        scheme.surface,
        scheme.onSurface,
        scheme.onSurfaceVariant,
        scheme.outline,
        scheme.outlineVariant,
      ];
      for (final color in used) {
        expect(
          {...allowed, if (name == 'dark') ...darkOnly},
          contains(color),
          reason: '$name uses $color',
        );
      }
    }
  });

  test('the dark red is the case red mixed 30% toward white', () {
    final mixed = Color.lerp(ColorName.error, ColorName.white, 0.3)!;
    const red = AppPalette.errorOnDark;
    for (final (a, b) in [
      (red.r, mixed.r),
      (red.g, mixed.g),
      (red.b, mixed.b),
    ]) {
      expect(a, closeTo(b, 1 / 255));
    }
  });

  test('dark text meets WCAG AA (4.5:1) on the surface it sits on', () {
    const c = AppPalette.darkColors;
    const s = AppPalette.darkSemantic;
    const scheme = AppPalette.darkScheme;
    final pairs = <String, (Color, Color)>{
      'title on card': (c.textTitle, c.card),
      'title on screen': (c.textTitle, scheme.surface),
      'title on selected card': (c.textTitle, scheme.primaryContainer),
      'secondary on screen': (c.textSecondary, scheme.surface),
      'caption on card': (c.textCaption, c.card),
      'hint on screen': (c.textHint, scheme.surface),
      'inactive tab': (c.textInactive, c.tabTrack),
      'inactive offer tab': (c.textSoft, c.tabTrackSoft),
      'active offer tab': (c.textStrong, c.tabPillActive),
      'accent on card': (c.accent, c.card),
      'accent on screen': (c.accent, scheme.surface),
      'button text': (scheme.onPrimary, scheme.primary),
      'pay amount on card': (s.success, c.card),
      'pay fits line': (s.success, c.fillMuted),
      'pay does not fit line': (s.warning, c.fillMuted),
      'accept button': (s.onSuccess, s.success),
      'accepted label': (s.onSuccessContainer, s.successContainer),
      'reject button': (
        scheme.onErrorContainer,
        Color.alphaBlend(scheme.errorContainer, c.card),
      ),
      'expired label': (c.textSecondary, c.fillSubtle),
      'countdown': (c.textStrong, c.card),
      // 12 px, so bold does not make it large text: 4.5:1 applies.
      'urgent countdown and detail error': (scheme.error, c.card),
      'on error': (scheme.onError, scheme.error),
    };
    for (final MapEntry(key: name, value: (fg, bg)) in pairs.entries) {
      expect(_contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: name);
    }
  });
}
