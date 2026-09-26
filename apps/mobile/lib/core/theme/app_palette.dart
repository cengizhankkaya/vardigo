import 'package:flutter/material.dart';

import '../../gen/colors.gen.dart';
import 'app_colors.dart';
import 'semantic_colors.dart';

/// Light and dark colours, picked only from the case palette
/// (`assets/colors/colors.xml`). This is the one place outside the phone
/// frame and the design gallery that names [ColorName] values.
///
/// Light is the reference design. Dark has no reference; it reuses the
/// case's darkest tokens (strong, slate-700, slate-600) as surfaces and keeps
/// text at WCAG AA contrast where the palette allows it.
abstract final class AppPalette {
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorName.primary,
    onPrimary: ColorName.white,
    primaryContainer: ColorName.primaryLighter,
    onPrimaryContainer: ColorName.slate700,
    secondary: ColorName.primary,
    onSecondary: ColorName.white,
    error: ColorName.error,
    onError: ColorName.white,
    errorContainer: ColorName.errorSoft,
    onErrorContainer: ColorName.error,
    surface: ColorName.white,
    onSurface: ColorName.strong,
    onSurfaceVariant: ColorName.sub,
    outline: ColorName.slate300,
    outlineVariant: ColorName.slate200,
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ColorName.primary,
    onPrimary: ColorName.white,
    primaryContainer: ColorName.primaryDarkest,
    onPrimaryContainer: ColorName.white,
    secondary: ColorName.primary,
    onSecondary: ColorName.white,
    error: ColorName.error,
    onError: ColorName.white,
    errorContainer: ColorName.errorSoft,
    onErrorContainer: ColorName.white,
    surface: ColorName.strong,
    onSurface: ColorName.white,
    onSurfaceVariant: ColorName.slate300,
    outline: ColorName.slate500,
    outlineVariant: ColorName.slate600,
  );

  static const lightColors = AppColors(
    card: ColorName.white,
    bar: ColorName.weak,
    tabTrack: ColorName.slate100,
    tabTrackSoft: ColorName.weak50,
    tabPillActive: ColorName.white,
    fillMuted: ColorName.slate50,
    fillSubtle: ColorName.weak50,
    placeholder: ColorName.slate100,
    backdrop: ColorName.slate100,
    border: ColorName.slate200,
    stroke: ColorName.stroke,
    borderStrong: ColorName.slate300,
    textStrong: ColorName.strong,
    textTitle: ColorName.slate700,
    textSecondary: ColorName.sub,
    textCaption: ColorName.gray500,
    // slate-500 at 80%, as the case gives it.
    textHint: Color(0xCC717784),
    textInactive: ColorName.slate500,
    textSoft: ColorName.soft,
    icon: ColorName.slate600,
    accent: ColorName.primary,
  );

  static const darkColors = AppColors(
    card: ColorName.slate700,
    bar: ColorName.strong,
    tabTrack: ColorName.slate700,
    tabTrackSoft: ColorName.slate700,
    tabPillActive: ColorName.slate600,
    fillMuted: ColorName.strong,
    fillSubtle: ColorName.strong,
    placeholder: ColorName.slate600,
    backdrop: ColorName.slate700,
    border: ColorName.slate600,
    stroke: ColorName.slate600,
    borderStrong: ColorName.slate500,
    textStrong: ColorName.white,
    textTitle: ColorName.white,
    textSecondary: ColorName.slate300,
    textCaption: ColorName.soft,
    textHint: ColorName.soft,
    textInactive: ColorName.soft,
    textSoft: ColorName.soft,
    icon: ColorName.slate300,
    accent: ColorName.primaryLight,
  );

  static const lightSemantic = SemanticColors(
    success: ColorName.green,
    onSuccess: ColorName.white,
    successContainer: ColorName.greenLighter,
    onSuccessContainer: ColorName.greenDark,
    warning: ColorName.warning,
    info: ColorName.primary,
  );

  static const darkSemantic = SemanticColors(
    success: ColorName.green,
    onSuccess: ColorName.strong,
    successContainer: ColorName.green,
    onSuccessContainer: ColorName.strong,
    warning: ColorName.warning,
    info: ColorName.primaryLight,
  );
}
