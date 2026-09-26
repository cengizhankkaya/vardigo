import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/shared/design_system/assets/app_icons.dart';
import 'package:vardigo/shared/design_system/components/app_icon.dart';

void main() {
  test('every icon has a bundled SVG file', () {
    for (final icon in AppIcons.values) {
      expect(File(icon.path).existsSync(), isTrue, reason: icon.path);
    }
  });

  testWidgets('tints only when a colour is given', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            AppIcon(AppIcons.shield, size: 16),
            AppIcon(AppIcons.star, size: 16, color: Color(0xFFFA7319)),
          ],
        ),
      ),
    );
    final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
    expect(pictures.first.colorFilter, isNull);
    expect(
      pictures.last.colorFilter,
      const ColorFilter.mode(Color(0xFFFA7319), BlendMode.srcIn),
    );
  });
}
