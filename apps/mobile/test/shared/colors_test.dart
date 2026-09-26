import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/gen/colors.gen.dart';

void main() {
  test('CSS #RRGGBBAA tokens keep their alpha', () {
    // Token: error-soft #FB37481A (10% of error).
    expect(ColorName.errorSoft, const Color(0x1AFB3748));
    expect(ColorName.errorSoft.withAlpha(255), ColorName.error);
  });

  test('main brand colours', () {
    expect(ColorName.primary, const Color(0xFF335CFF));
    expect(ColorName.green, const Color(0xFF1DAF61));
    expect(ColorName.strong, const Color(0xFF171717));
  });
}
