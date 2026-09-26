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
  String get galleryTextStyleSection => 'Yazı stilleri';

  @override
  String get galleryColorSection => 'Renkler';

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

  @override
  String get roleTitle => 'Demo hesabı seç';

  @override
  String get roleSubtitle => 'Case\'teki iki sabit hesaptan biriyle devam et.';

  @override
  String get roleEmployer => 'İşveren';

  @override
  String get roleEmployerHint =>
      'Eşleşen personelleri gör, görüşme talebi gönder';

  @override
  String get roleWorker => 'İş arayan';

  @override
  String get roleWorkerHint => 'Gelen görüşme taleplerini gör, yanıtla';

  @override
  String get openGallery => 'Tasarım galerisi';

  @override
  String get appearance => 'Görünüm';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get candidatesTitle => 'Eşleşen Personeller';

  @override
  String candidatesFound(int count) {
    return '$count personel bulundu';
  }

  @override
  String tabPerfect(int count) {
    return '%100 Eşleşme ($count)';
  }

  @override
  String tabSimilar(int count) {
    return 'Benzer Personeller ($count)';
  }

  @override
  String selectedCount(int count) {
    return '$count kişi seçildi';
  }

  @override
  String sortLabel(String option) {
    return 'Sırala: $option';
  }

  @override
  String get sortRecommended => 'Önerilen';

  @override
  String get sortNear => 'En Yakın';

  @override
  String get sortRating => 'Puan';

  @override
  String get payMatches => 'Ücret beklentisi uyuşuyor';

  @override
  String get payMismatch => 'Ücret beklentisi uyuşmuyor';

  @override
  String payPerMonth(String amount) {
    return '₺$amount / ay';
  }

  @override
  String get candidatesEmpty => 'Bu sekmede aday yok';

  @override
  String requestsSent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kişiye görüşme talebi gönderildi',
      one: '1 kişiye görüşme talebi gönderildi',
    );
    return '$_temp0';
  }

  @override
  String get sendUncertain =>
      'Sunucudan yanıt alınamadı; talebin gönderilip gönderilmediği doğrulanamadı. İş arayan hesabından kontrol edebilir veya tekrar deneyebilirsin.';

  @override
  String get helpTitle => 'Bu ekran';

  @override
  String get candidatesHelp =>
      'İlan için eşleşen personeller listelenir. Kişileri seçip görüşme talebi gönderebilirsin; seçimler sekmeler arasında korunur.';

  @override
  String get back => 'Geri';

  @override
  String get help => 'Yardım';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get errorNetwork =>
      'Sunucuya ulaşılamadı. Backend\'in çalıştığından emin olup tekrar dene.';

  @override
  String get errorTimeout => 'Sunucu zamanında yanıt vermedi. Tekrar dene.';

  @override
  String get errorUnexpected => 'Beklenmeyen bir hata oluştu. Tekrar dene.';

  @override
  String get offersTitle => 'Görüşme Talepleri';

  @override
  String offersPendingSubtitle(int count) {
    return '$count talep yanıt bekliyor';
  }

  @override
  String get offersAnsweredSubtitle => 'Cevaplanan talepler';

  @override
  String get offersExpiredSubtitle => 'Süresi dolan talepler';

  @override
  String get tabPending => 'Bekleyen';

  @override
  String get tabAnswered => 'Cevaplanan';

  @override
  String get tabExpired => 'Süresi Dolan';

  @override
  String get emptyPending => 'Bekleyen talep yok';

  @override
  String get emptyAnswered =>
      'Kabul veya red ettiğin talepler burada listelenir';

  @override
  String get emptyExpired => 'Süresi dolan talep yok';

  @override
  String get sortExpiring => 'Süresi Yakın';

  @override
  String get sortPay => 'Ücret';

  @override
  String payAmount(String amount) {
    return '₺$amount';
  }

  @override
  String get viewDetails => 'Detayları Gör';

  @override
  String get hideDetails => 'Detayları Gizle';

  @override
  String countdown(String time) {
    return 'Teklifin sonlanmasına $time kaldı.';
  }

  @override
  String hoursMinutes(int hours, int minutes) {
    return '$hours saat $minutes dakika';
  }

  @override
  String get statusAccepted => 'İlgileniyorsun';

  @override
  String get statusRejected => 'İlgilenmiyorsun';

  @override
  String get statusExpired => 'Süresi doldu';

  @override
  String offerAccepted(String title) {
    return '$title talebine ilgilendiğini bildirdin';
  }

  @override
  String offerRejected(String title) {
    return '$title talebini reddettin';
  }

  @override
  String detailPlace(String district, String city, String note) {
    return '$district, $city · $note';
  }

  @override
  String detailPayWhen(String pay, String when) {
    return '$pay · $when';
  }
}
