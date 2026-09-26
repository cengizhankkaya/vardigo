import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../shared/design_system/assets/app_icons.dart';
import '../shared/design_system/components/app_icon.dart';

/// Development gallery: fonts and icons as they render on the device,
/// to catch a wrong weight or an unsupported SVG before building screens.
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.white,
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
                for (final icon in AppIcons.values)
                  SizedBox(
                    width: 64,
                    child: Column(
                      children: [
                        AppIcon(icon, size: 24),
                        const SizedBox(height: 4),
                        _text(icon.name, 11, FontWeight.w400),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _section(l10n.galleryUsageSection),
            Row(
              children: [
                const AppIcon(AppIcons.star, color: Color(0xFFFA7319)),
                const SizedBox(width: 4),
                _text('4.9', 12, FontWeight.w500),
                const SizedBox(width: 12),
                const AppIcon(AppIcons.shield),
                const SizedBox(width: 4),
                _text('%100 katılım', 12, FontWeight.w500),
                const SizedBox(width: 12),
                const AppIcon(AppIcons.pin, size: 14),
                const SizedBox(width: 4),
                _text('4.9 km', 12, FontWeight.w500),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const AppIcon(AppIcons.money, size: 24),
                const SizedBox(width: 4),
                _text(
                  '45.000',
                  18,
                  FontWeight.w600,
                  color: const Color(0xFF1DAF61),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _button(
                    AppIcons.close,
                    l10n.notInterested,
                    const Color(0xFFFB3748),
                    const Color(0x1AFB3748),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _button(
                    AppIcons.check,
                    l10n.interested,
                    Colors.white,
                    const Color(0xFF1DAF61),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _button(
              AppIcons.send,
              l10n.sendRequest(1),
              Colors.white,
              const Color(0xFF335CFF),
              height: 44,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: _text(title, 13, FontWeight.w600, color: const Color(0xFF7B7B7B)),
  );

  static Widget _text(
    String text,
    double size,
    FontWeight weight, {
    Color color = const Color(0xFF171717),
  }) => Text(
    text,
    style: TextStyle(
      fontFamily: 'Urbanist',
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
    AppIcons icon,
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
