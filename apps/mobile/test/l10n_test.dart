import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vardigo/l10n/l10n.dart';

void main() {
  test('Turkish is the only and default locale', () {
    expect(AppLocalizations.supportedLocales, [const Locale('tr')]);
  });

  test('fills placeholders', () {
    final l10n = lookupAppLocalizations(const Locale('tr'));
    expect(l10n.sendRequest(3), 'Görüşme Talebi Gönder (3)');
  });
}
