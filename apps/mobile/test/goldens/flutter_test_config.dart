import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Golden tests only: draw with the real Urbanist instead of the test font,
/// and let a few edge pixels differ between runs.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final urbanist = FontLoader('Urbanist');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final bytes = File('assets/fonts/urbanist/Urbanist-$weight.ttf')
        .readAsBytesSync();
    urbanist.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await urbanist.load();

  // Urbanist has no ₺; phones fall back to a system font, tests have none.
  // Roboto ships with the Flutter SDK.
  final roboto = FontLoader('Roboto');
  final sdkFonts =
      '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
  for (final weight in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('$sdkFonts/Roboto-$weight.ttf').readAsBytesSync();
    roboto.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await roboto.load();

  final local = goldenFileComparator as LocalFileComparator;
  goldenFileComparator = _TolerantComparator(local.basedir.resolve('_'));
  await testMain();
}

/// Passes when at most [_tolerance] of the pixels differ: a layout change
/// moves far more. The PNGs are drawn and checked on macOS (see
/// dart_test.yaml); Linux rasterises text too differently for this.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const _tolerance = 0.005;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    try {
      if (result.passed || result.diffPercent <= _tolerance) return true;
      throw FlutterError(await generateFailureOutput(result, golden, basedir));
    } finally {
      result.dispose();
    }
  }
}
