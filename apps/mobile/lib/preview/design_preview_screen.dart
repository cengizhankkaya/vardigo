import 'package:flutter/material.dart';

import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';
import '../l10n/l10n.dart';
import '../shared/design_system/components/app_icon.dart';
import '../shared/design_system/tokens/app_dimens.dart';
import '../shared/design_system/tokens/app_text_styles.dart';

/// Development gallery: fonts, text styles, colours and icons as they render
/// on the device, to catch a wrong token before building screens.
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  static const _textStyles = {
    'statusTime 17/700/22': AppTextStyles.statusTime,
    'title20 20/600/28': AppTextStyles.title20,
    'title18 18/500/24': AppTextStyles.title18,
    'title16Medium 16/500/24': AppTextStyles.title16Medium,
    'title16Semibold 16/600/24': AppTextStyles.title16Semibold,
    'caption13 13/400/20': AppTextStyles.caption13,
    'caption12Medium 12/500/16': AppTextStyles.caption12Medium,
    'caption12 12/400/16': AppTextStyles.caption12,
    'label14 14/500/20': AppTextStyles.label14,
    'tab13 13/500': AppTextStyles.tab13,
  };

  static const _colors = {
    'primary': ColorName.primary,
    'primaryLighter': ColorName.primaryLighter,
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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            Text(l10n.galleryTitle, style: AppTextStyles.title20),
            const SizedBox(height: 16),
            _section(l10n.galleryFontSection),
            for (final weight in const [400, 500, 600, 700])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '$weight  ${l10n.galleryFontSample}',
                  style: AppTextStyles.title16Medium.copyWith(
                    color: ColorName.strong,
                    fontWeight: FontWeight.values[weight ~/ 100 - 1],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _section(l10n.galleryTextStyleSection),
            for (final entry in _textStyles.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(entry.key, style: entry.value),
              ),
            const SizedBox(height: 16),
            _section(l10n.galleryColorSection),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in _colors.entries)
                  SizedBox(
                    width: 76,
                    child: Column(
                      children: [
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: ColorName.stroke),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(entry.key, style: AppTextStyles.caption12),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _section(l10n.galleryIconSection),
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
                        Text(_iconName(icon), style: AppTextStyles.caption12),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _section(l10n.galleryUsageSection),
            Row(
              children: [
                AppIcon(Assets.icons.star, color: ColorName.warning),
                const SizedBox(width: AppSpacing.iconText),
                const Text('4.9', style: AppTextStyles.caption12Medium),
                const SizedBox(width: 12),
                AppIcon(Assets.icons.shield),
                const SizedBox(width: AppSpacing.iconText),
                const Text('%100', style: AppTextStyles.caption12Medium),
                const SizedBox(width: 12),
                AppIcon(Assets.icons.pin, size: 14),
                const SizedBox(width: AppSpacing.iconText),
                const Text('4.9 km', style: AppTextStyles.caption12Medium),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AppIcon(Assets.icons.money, size: 24),
                const SizedBox(width: AppSpacing.iconText),
                Text(
                  '45.000',
                  style: AppTextStyles.title16Semibold.copyWith(
                    color: ColorName.green,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _button(
                    Assets.icons.close,
                    l10n.notInterested,
                    ColorName.error,
                    ColorName.errorSoft,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _button(
                    Assets.icons.check,
                    l10n.interested,
                    ColorName.white,
                    ColorName.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _button(
              Assets.icons.send,
              l10n.sendRequest(1),
              ColorName.white,
              ColorName.primary,
              height: AppSizes.cta,
              radius: AppRadius.cta,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  static String _iconName(SvgGenImage icon) =>
      icon.path.split('/').last.replaceAll('.svg', '');

  static Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: AppTextStyles.caption13.copyWith(fontWeight: FontWeight.w600),
    ),
  );

  static Widget _button(
    SvgGenImage icon,
    String label,
    Color foreground,
    Color background, {
    double height = AppSizes.actionButton,
    double radius = AppRadius.actionButton,
    double iconSize = 16,
  }) => Container(
    height: height,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(icon, size: iconSize, color: foreground),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.label14.copyWith(color: foreground)),
      ],
    ),
  );
}
