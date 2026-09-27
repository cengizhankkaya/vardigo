import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../controllers/theme_mode_controller.dart';

/// Light / dark toggle. Shows the theme on screen, so a saved "system"
/// choice reads as whatever the device picked; flipping it saves light or
/// dark explicitly.
class ThemeModeSwitch extends ConsumerWidget {
  const ThemeModeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ColorScheme.of(context);
    final colors = context.appColors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: context.l10n.themeDark,
      child: Switch(
        value: dark,
        onChanged: (on) => ref
            .read(themeModeControllerProvider.notifier)
            .setMode(on ? AppThemeMode.dark : AppThemeMode.light),
        thumbIcon: WidgetStatePropertyAll(
          Icon(
            dark ? Icons.dark_mode : Icons.light_mode,
            color: dark ? scheme.primary : colors.icon,
          ),
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        activeTrackColor: scheme.primary,
        inactiveTrackColor: colors.tabTrack,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
