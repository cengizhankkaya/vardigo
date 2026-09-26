import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/pill_tabs.dart';
import '../../../../core/presentation/widgets/pill_tabs_style.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_shadows.dart';
import '../../domain/entities/app_theme_mode.dart';
import '../controllers/theme_mode_controller.dart';

/// "Görünüm": Sistem / Açık / Koyu.
class ThemeModePicker extends ConsumerWidget {
  const ThemeModePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final mode = ref.watch(themeModeControllerProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.appearance, style: context.textStyles.caption13),
        const SizedBox(height: 8),
        PillTabs(
          tabs: [
            (AppThemeMode.system, l10n.themeSystem),
            (AppThemeMode.light, l10n.themeLight),
            (AppThemeMode.dark, l10n.themeDark),
          ],
          selected: mode,
          onSelected: ref.read(themeModeControllerProvider.notifier).setMode,
          style: PillTabsStyle(
            background: colors.tabTrackSoft,
            radius: 54,
            pillRadius: 26,
            pillPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 10,
            ),
            activeColor: colors.tabPillActive,
            activeShadow: AppShadows.offerTabActive,
            textStyle: context.textStyles.tab13,
            activeTextColor: colors.textStrong,
            inactiveTextColor: colors.textSoft,
            gap: 4,
          ),
        ),
      ],
    );
  }
}
