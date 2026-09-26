import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('tr')];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'Vardigo'**
  String get appTitle;

  /// No description provided for @galleryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tasarım galerisi'**
  String get galleryTitle;

  /// No description provided for @galleryFontSection.
  ///
  /// In tr, this message translates to:
  /// **'Urbanist'**
  String get galleryFontSection;

  /// No description provided for @galleryFontSample.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen Personeller · ğüşıöç İŞĞ ₺25.000'**
  String get galleryFontSample;

  /// No description provided for @galleryTextStyleSection.
  ///
  /// In tr, this message translates to:
  /// **'Yazı stilleri'**
  String get galleryTextStyleSection;

  /// No description provided for @galleryColorSection.
  ///
  /// In tr, this message translates to:
  /// **'Renkler'**
  String get galleryColorSection;

  /// No description provided for @galleryIconSection.
  ///
  /// In tr, this message translates to:
  /// **'İkonlar (orijinal renk, 24)'**
  String get galleryIconSection;

  /// No description provided for @galleryUsageSection.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım örnekleri'**
  String get galleryUsageSection;

  /// No description provided for @notInterested.
  ///
  /// In tr, this message translates to:
  /// **'İlgilenmiyorum'**
  String get notInterested;

  /// No description provided for @interested.
  ///
  /// In tr, this message translates to:
  /// **'İlgileniyorum'**
  String get interested;

  /// No description provided for @sendRequest.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme Talebi Gönder ({count})'**
  String sendRequest(int count);

  /// No description provided for @roleTitle.
  ///
  /// In tr, this message translates to:
  /// **'Demo hesabı seç'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Case\'teki iki sabit hesaptan biriyle devam et.'**
  String get roleSubtitle;

  /// No description provided for @roleEmployer.
  ///
  /// In tr, this message translates to:
  /// **'İşveren'**
  String get roleEmployer;

  /// No description provided for @roleEmployerHint.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen personelleri gör, görüşme talebi gönder'**
  String get roleEmployerHint;

  /// No description provided for @roleWorker.
  ///
  /// In tr, this message translates to:
  /// **'İş arayan'**
  String get roleWorker;

  /// No description provided for @roleWorkerHint.
  ///
  /// In tr, this message translates to:
  /// **'Gelen görüşme taleplerini gör, yanıtla'**
  String get roleWorkerHint;

  /// No description provided for @openGallery.
  ///
  /// In tr, this message translates to:
  /// **'Tasarım galerisi'**
  String get openGallery;

  /// No description provided for @candidatesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Eşleşen Personeller'**
  String get candidatesTitle;

  /// No description provided for @candidatesFound.
  ///
  /// In tr, this message translates to:
  /// **'{count} personel bulundu'**
  String candidatesFound(int count);

  /// No description provided for @tabPerfect.
  ///
  /// In tr, this message translates to:
  /// **'%100 Eşleşme ({count})'**
  String tabPerfect(int count);

  /// No description provided for @tabSimilar.
  ///
  /// In tr, this message translates to:
  /// **'Benzer Personeller ({count})'**
  String tabSimilar(int count);

  /// No description provided for @selectedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} kişi seçildi'**
  String selectedCount(int count);

  /// No description provided for @sortLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sırala: {option}'**
  String sortLabel(String option);

  /// No description provided for @sortRecommended.
  ///
  /// In tr, this message translates to:
  /// **'Önerilen'**
  String get sortRecommended;

  /// No description provided for @sortNear.
  ///
  /// In tr, this message translates to:
  /// **'En Yakın'**
  String get sortNear;

  /// No description provided for @sortRating.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get sortRating;

  /// No description provided for @payMatches.
  ///
  /// In tr, this message translates to:
  /// **'Ücret beklentisi uyuşuyor'**
  String get payMatches;

  /// No description provided for @payMismatch.
  ///
  /// In tr, this message translates to:
  /// **'Ücret beklentisi uyuşmuyor'**
  String get payMismatch;

  /// No description provided for @payPerMonth.
  ///
  /// In tr, this message translates to:
  /// **'₺{amount} / ay'**
  String payPerMonth(String amount);

  /// No description provided for @candidatesEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Bu sekmede aday yok'**
  String get candidatesEmpty;

  /// No description provided for @requestsSent.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 kişiye görüşme talebi gönderildi} other{{count} kişiye görüşme talebi gönderildi}}'**
  String requestsSent(int count);

  /// No description provided for @sendUncertain.
  ///
  /// In tr, this message translates to:
  /// **'Sunucudan yanıt alınamadı; talebin gönderilip gönderilmediği doğrulanamadı. İş arayan hesabından kontrol edebilir veya tekrar deneyebilirsin.'**
  String get sendUncertain;

  /// No description provided for @helpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekran'**
  String get helpTitle;

  /// No description provided for @candidatesHelp.
  ///
  /// In tr, this message translates to:
  /// **'İlan için eşleşen personeller listelenir. Kişileri seçip görüşme talebi gönderebilirsin; seçimler sekmeler arasında korunur.'**
  String get candidatesHelp;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get help;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @errorNetwork.
  ///
  /// In tr, this message translates to:
  /// **'Sunucuya ulaşılamadı. Backend\'in çalıştığından emin olup tekrar dene.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu zamanında yanıt vermedi. Tekrar dene.'**
  String get errorTimeout;

  /// No description provided for @errorUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen bir hata oluştu. Tekrar dene.'**
  String get errorUnexpected;

  /// No description provided for @offersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme Talepleri'**
  String get offersTitle;

  /// No description provided for @offersPendingSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{count} talep yanıt bekliyor'**
  String offersPendingSubtitle(int count);

  /// No description provided for @offersAnsweredSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Cevaplanan talepler'**
  String get offersAnsweredSubtitle;

  /// No description provided for @offersExpiredSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Süresi dolan talepler'**
  String get offersExpiredSubtitle;

  /// No description provided for @tabPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen'**
  String get tabPending;

  /// No description provided for @tabAnswered.
  ///
  /// In tr, this message translates to:
  /// **'Cevaplanan'**
  String get tabAnswered;

  /// No description provided for @tabExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi Dolan'**
  String get tabExpired;

  /// No description provided for @emptyPending.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen talep yok'**
  String get emptyPending;

  /// No description provided for @emptyAnswered.
  ///
  /// In tr, this message translates to:
  /// **'Kabul veya red ettiğin talepler burada listelenir'**
  String get emptyAnswered;

  /// No description provided for @emptyExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi dolan talep yok'**
  String get emptyExpired;

  /// No description provided for @sortExpiring.
  ///
  /// In tr, this message translates to:
  /// **'Süresi Yakın'**
  String get sortExpiring;

  /// No description provided for @sortPay.
  ///
  /// In tr, this message translates to:
  /// **'Ücret'**
  String get sortPay;

  /// No description provided for @payAmount.
  ///
  /// In tr, this message translates to:
  /// **'₺{amount}'**
  String payAmount(String amount);

  /// No description provided for @viewDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detayları Gör'**
  String get viewDetails;

  /// No description provided for @hideDetails.
  ///
  /// In tr, this message translates to:
  /// **'Detayları Gizle'**
  String get hideDetails;

  /// No description provided for @countdown.
  ///
  /// In tr, this message translates to:
  /// **'Teklifin sonlanmasına {time} kaldı.'**
  String countdown(String time);

  /// No description provided for @hoursMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{hours} saat {minutes} dakika'**
  String hoursMinutes(int hours, int minutes);

  /// No description provided for @statusAccepted.
  ///
  /// In tr, this message translates to:
  /// **'İlgileniyorsun'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In tr, this message translates to:
  /// **'İlgilenmiyorsun'**
  String get statusRejected;

  /// No description provided for @statusExpired.
  ///
  /// In tr, this message translates to:
  /// **'Süresi doldu'**
  String get statusExpired;

  /// No description provided for @offerAccepted.
  ///
  /// In tr, this message translates to:
  /// **'{title} talebine ilgilendiğini bildirdin'**
  String offerAccepted(String title);

  /// No description provided for @offerRejected.
  ///
  /// In tr, this message translates to:
  /// **'{title} talebini reddettin'**
  String offerRejected(String title);

  /// No description provided for @detailPlace.
  ///
  /// In tr, this message translates to:
  /// **'{district}, {city} · {note}'**
  String detailPlace(String district, String city, String note);

  /// No description provided for @detailPayWhen.
  ///
  /// In tr, this message translates to:
  /// **'{pay} · {when}'**
  String detailPayWhen(String pay, String when);

  /// No description provided for @offersHelp.
  ///
  /// In tr, this message translates to:
  /// **'İşverenlerin sana gönderdiği görüşme talepleri burada. Süresi dolmadan İlgileniyorum veya İlgilenmiyorum diyebilirsin; kararın kaydedilir ve Cevaplanan sekmesine geçer.'**
  String get offersHelp;

  /// No description provided for @offersComingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Görüşme Talepleri ekranı sonraki adımda eklenecek.'**
  String get offersComingSoon;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
