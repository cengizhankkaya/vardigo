import 'package:flutter/material.dart';

import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';
import '../gen/fonts.gen.dart';
import '../l10n/l10n.dart';
import '../shared/design_system/components/app_icon.dart';

/// Development gallery: fonts and icons as they render on the device,
/// to catch a wrong weight or an unsupported SVG before building screens.
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: ColorName.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _text(l10n.galleryTitle, 20, FontWeight.w600),
            const SizedBox(height: 16),
            _section(l10n.galleryFontSection),
            for (final weight in [400, 500, 600, 700])
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _text(
                  '$weight  ${l10n.galleryFontSample}',
                  16,
                  FontWeight.values[weight ~/ 100 - 1],
                ),
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
                        _text(_iconName(icon), 11, FontWeight.w400),
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
                const SizedBox(width: 4),
                _text('4.9', 12, FontWeight.w500),
                const SizedBox(width: 12),
                AppIcon(Assets.icons.shield),
                const SizedBox(width: 4),
                _text('%100 katılım', 12, FontWeight.w500),
                const SizedBox(width: 12),
                AppIcon(Assets.icons.pin, size: 14),
                const SizedBox(width: 4),
                _text('4.9 km', 12, FontWeight.w500),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AppIcon(Assets.icons.money, size: 24),
                const SizedBox(width: 4),
                _text('45.000', 18, FontWeight.w600, color: ColorName.green),
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
              height: 44,
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
    child: _text(title, 13, FontWeight.w600, color: ColorName.gray500),
  );

  static Widget _text(
    String text,
    double size,
    FontWeight weight, {
    Color color = ColorName.strong,
  }) => Text(
    text,
    style: TextStyle(
      fontFamily: FontFamily.urbanist,
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [
        FontFeature.disable('liga'),
        FontFeature.disable('calt'),
      ],
    ),
  );

  static Widget _button(
    SvgGenImage icon,
    String label,
    Color foreground,
    Color background, {
    double height = 36,
    double iconSize = 16,
  }) => Container(
    height: height,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIcon(icon, size: iconSize, color: foreground),
        const SizedBox(width: 8),
        _text(label, 14, FontWeight.w500, color: foreground),
      ],
    ),
  );
}
