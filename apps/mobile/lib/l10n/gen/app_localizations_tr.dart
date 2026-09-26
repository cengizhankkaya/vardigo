// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Vardigo';

  @override
  String get galleryTitle => 'Tasarım galerisi';

  @override
  String get galleryFontSection => 'Urbanist';

  @override
  String get galleryFontSample => 'Eşleşen Personeller · ğüşıöç İŞĞ ₺25.000';

  @override
  String get galleryIconSection => 'İkonlar (orijinal renk, 24)';

  @override
  String get galleryUsageSection => 'Kullanım örnekleri';

  @override
  String get notInterested => 'İlgilenmiyorum';

  @override
  String get interested => 'İlgileniyorum';

  @override
  String sendRequest(int count) {
    return 'Görüşme Talebi Gönder ($count)';
  }
}
