import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/gen/assets.gen.dart';
import 'package:vardigo/gen/colors.gen.dart';
import 'package:vardigo/shared/design_system/components/app_icon.dart';

void main() {
  test('generated icon list matches the files on disk', () {
    final onDisk = Directory('assets/icons')
        .listSync()
        .map((f) => f.path.replaceAll(r'\', '/'))
        .where((p) => p.endsWith('.svg'))
        .toSet();
    expect(Assets.icons.values.map((i) => i.path).toSet(), onDisk);
    expect(onDisk, hasLength(15));
  });

  testWidgets('tints only when a colour is given', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [
            AppIcon(Assets.icons.shield),
            AppIcon(Assets.icons.star, color: ColorName.warning),
          ],
        ),
      ),
    );
    final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
    expect(pictures.first.colorFilter, isNull);
    expect(
      pictures.last.colorFilter,
      const ColorFilter.mode(ColorName.warning, BlendMode.srcIn),
    );
  });
}
