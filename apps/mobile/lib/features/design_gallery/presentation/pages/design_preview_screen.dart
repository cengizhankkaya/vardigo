import 'package:flutter/material.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/widgets/action_button.dart';
import '../../../../core/presentation/widgets/app_icon.dart';
import '../../../../core/presentation/widgets/primary_button.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/tokens/app_dimens.dart';

/// Development gallery: fonts, text styles, colours and icons as they render
/// on the device, to catch a wrong token before building screens. Follows
/// the current theme; the palette swatches show the raw case colours.
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  static const _palette = {
    'primary': ColorName.primary,
    'primaryLighter': ColorName.primaryLighter,
    'primaryDarkest': ColorName.primaryDarkest,
    'strong': ColorName.strong,
    'slate700': ColorName.slate700,
    'slate500': ColorName.slate500,
    'gray500': ColorName.gray500,
    'slate200': ColorName.slate200,
    'green': ColorName.green,
    'error': ColorName.error,
    'errorSoft': ColorName.errorSoft,
    'warning': ColorName.warning,
    'weak': ColorName.weak,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.textStyles;
    final colors = context.appColors;
    final semantic = context.semanticColors;
    final scheme = ColorScheme.of(context);
    final textStyles = {
      'statusTime 17/700/22': text.statusTime,
      'title20 20/600/28': text.title20,
      'title18 18/500/24': text.title18,
      'title16Medium 16/500/24': text.title16Medium,
      'title16Semibold 16/600/24': text.title16Semibold,
      'caption13 13/400/20': text.caption13,
      'caption12Medium 12/500/16': text.caption12Medium,
      'caption12 12/400/16': text.caption12,
      'label14 14/500/20': text.label14,
      'tab13 13/500': text.tab13,
    };
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: text.caption13.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(l10n.galleryTitle, style: text.title20),
            const SizedBox(height: 16),
            section(l10n.galleryFontSection),
            for (final weight in const [400, 500, 600, 700])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '$weight  ${l10n.galleryFontSample}',
                  style: text.title16Medium.copyWith(
                    color: colors.textStrong,
                    fontWeight: FontWeight.values[weight ~/ 100 - 1],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            section(l10n.galleryTextStyleSection),
            for (final entry in textStyles.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(entry.key, style: entry.value),
              ),
            const SizedBox(height: 16),
            section(l10n.galleryColorSection),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _palette.entries)
                  SizedBox(
                    width: 76,
                    child: Column(
                      children: [
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.stroke),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(entry.key, style: text.caption12),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            section(l10n.galleryIconSection),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final icon in Assets.icons.values)
                  SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        AppIcon(icon, size: 24),
                        const SizedBox(height: 4),
                        Text(_iconName(icon), style: text.caption12),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            section(l10n.galleryUsageSection),
            Row(
              children: [
                AppIcon(Assets.icons.star, color: semantic.warning),
                const SizedBox(width: AppSpacing.iconText),
                Text('4.9', style: text.caption12Medium),
                const SizedBox(width: 12),
                AppIcon(Assets.icons.shield),
                const SizedBox(width: AppSpacing.iconText),
                Text('%100', style: text.caption12Medium),
                const SizedBox(width: 12),
                AppIcon(Assets.icons.pin, size: 14),
                const SizedBox(width: AppSpacing.iconText),
                Text('4.9 km', style: text.caption12Medium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AppIcon(Assets.icons.money, size: 24),
                const SizedBox(width: AppSpacing.iconText),
                Text(
                  '45.000',
                  style: text.title16Semibold.copyWith(
                    color: semantic.success,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ActionButton(
                    icon: Assets.icons.close,
                    label: l10n.notInterested,
                    foreground: scheme.onErrorContainer,
                    background: scheme.errorContainer,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                    icon: Assets.icons.check,
                    label: l10n.interested,
                    foreground: semantic.onSuccess,
                    background: semantic.success,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              icon: Assets.icons.send,
              label: l10n.sendRequest(1),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  static String _iconName(SvgGenImage icon) =>
      icon.path.split('/').last.replaceAll('.svg', '');
}
