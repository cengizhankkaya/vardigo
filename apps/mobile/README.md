# Flutter mobil

Flutter / Dart ile iOS ve Android uygulaması. İki case ekranı burada geliştirilir.

## Gereksinim

- Flutter 3.47 (stable), Dart 3.13
- iOS için Xcode ve bir simülatör; Android için Android Studio ve bir emülatör

`flutter doctor` eksik araçları gösterir.

## Komutlar

```bash
cd apps/mobile
flutter pub get
flutter run          # açık simülatör/emülatör veya bağlı cihazda başlatır
flutter run --dart-define=START_AS=employer   # rol ekranını atlayıp işveren olarak açar (worker: iş arayan)
flutter run --dart-define=REFERENCE_FRAME=true   # uygulamayı 390×844 telefon çerçevesinde gösterir
flutter analyze
flutter test
flutter test --update-goldens test/goldens   # bilerek yapılan görsel değişiklikten sonra
```

## Backend bağlantısı

Uygulama backend'e `http` ile bağlanır. Varsayılan adres platforma göre seçilir:

| Nerede | Adres | Backend |
|---|---|---|
| iOS simülatörü | `http://127.0.0.1:3000` | `npm run dev` |
| Android emülatörü | `http://10.0.2.2:3000` (emülatörden bilgisayara) | `npm run dev` |
| Gerçek telefon (aynı Wi-Fi) | `flutter run --dart-define=API_ORIGIN=http://<bilgisayar-IP>:3000` | `HOST=0.0.0.0 npm run dev` |

- iOS'ta yalnız yerel ağ için `http` izni açıktır (`NSAllowsLocalNetworking`); Android'de şifresiz trafik yalnız debug derlemede açıktır.
- Katmanlar: ekranlar use case'leri çağırır, use case'ler `I…Repository` port'larını kullanır, `…RepositoryImpl` adaptörleri JSON'u okuyup Dio ile API'ye gider. Adaptörleri yalnız `app/composition_root.dart` bağlar (ayrıntı: [Klasörler](#klasörler)).
- Hatalar `ApiException` olarak gelir: backend kodu (`OFFER_EXPIRED`...) ve Türkçe mesajı ya da istemci kodu (`NETWORK_ERROR`, `TIMEOUT`, `BAD_RESPONSE`).
- [test/fixtures/](test/fixtures/) backend'in gerçek yanıtlarıdır; repository testleri bunları okur. Backend yanıtı değişirse fixture'lar yeniden alınmalıdır.
- Canlı test, case akışını uygulamanın repository'leri üzerinden gerçek sunucuya karşı çalıştırır (CI'da her push'ta da çalışır):

```bash
cd apps/api && npm run db:reset && npm run dev       # 1. terminal
cd apps/mobile && LIVE_API_ORIGIN=http://127.0.0.1:3000 flutter test test/live   # 2. terminal
```

## Kod üretimi: asset, renk, font ve metin

Kodda dosya yolu, hex renk, font adı veya Türkçe metin elle yazılmaz; hepsi üretilen sınıflardan okunur.

| Ne | Düzenlenen kaynak | Üretilen dosya | Kullanım |
|---|---|---|---|
| İkonlar | `assets/icons/*.svg` | `lib/gen/assets.gen.dart` | `AppIcon(Assets.icons.star, color: ColorName.warning)` |
| Renkler | `assets/colors/colors.xml` | `lib/gen/colors.gen.dart` | `ColorName.primary`, `ColorName.errorSoft` |
| Font | `pubspec.yaml` → `fonts` | `lib/gen/fonts.gen.dart` | `FontFamily.urbanist` |
| Metinler | `lib/core/l10n/app_tr.arb` | `lib/core/l10n/gen/` | `context.l10n.sendRequest(2)` |

Kaynak dosyayı değiştirdikten sonra:

```bash
dart run build_runner build --delete-conflicting-outputs   # assets, renkler, font (FlutterGen)
flutter gen-l10n                                           # metinler (flutter run/pub get de üretir)
```

Üretilen dosyalar depoya dahildir; CI, kaynakla uyumsuz kalırlarsa hata verir.

- **Renkler** case'in design token listesindeki adlarla tutulur (`slate-700` → `ColorName.slate700`). XML'de alfa başta yazılır: CSS `#FB37481A` → `#1AFB3748`.
- **Metinler** şimdilik yalnız Türkçe (`tr`). Yeni metin: `app_tr.arb` dosyasına anahtar ekle, `flutter gen-l10n` çalıştır, `context.l10n.anahtar` ile kullan. Yer tutuculu metinler (`{count}`) ARB'de tip bilgisiyle tanımlanır.

## Tema ve token'lar

Uygulamanın açık (referans tasarım) ve koyu teması vardır. Seçim rol ekranının sağ üstündeki **açık/koyu anahtarı** ile yapılır, cihazda saklanır ve uygulama yeniden açıldığında korunur. Varsayılan **Açık**tır: cihaz koyu moddayken de case ekranları referansla aynı açılır; koyu tema yalnız seçilince devreye girer.

### Yapı

```text
lib/core/theme/                # tema yapılandırması (yalnız veri, durum yok)
├── tokens/                    # renksiz ölçüler
│   ├── app_text_styles.dart   # yazı boyutları
│   ├── app_spacing.dart, app_radius.dart, app_sizes.dart, app_frame.dart
│   └── app_shadows.dart
├── app_palette.dart           # açık/koyu renk setleri; yalnız case paleti (ColorName)
├── app_colors.dart            # ThemeExtension: metin seviyeleri, yüzeyler, kenarlıklar
├── semantic_colors.dart       # ThemeExtension: success, warning, info
├── app_text_theme.dart        # ThemeExtension: case'in 10 yazı stili, temanın renkleriyle
├── app_theme.dart             # AppTheme.light() / AppTheme.dark()
├── theme_context.dart         # context.appColors / semanticColors / textStyles
└── theme.dart                 # barrel

lib/features/appearance/                       # tema durumu (Riverpod)
├── domain/entities/app_theme_mode.dart        # AppThemeMode { system, light, dark }
├── domain/repositories/theme_mode_repository.dart
├── application/                               # port provider'ı, GetThemeMode / SaveThemeMode
├── infrastructure/repositories/               # ThemeModeRepositoryImpl (shared_preferences)
├── presentation/controllers/theme_mode_controller.dart  # themeModeControllerProvider
└── presentation/widgets/theme_mode_switch.dart          # açık/koyu anahtarı
```

### Kurallar

- Widget'ta renk yazılmaz; `ColorName` yalnız `app_palette.dart`'ta, telefon çerçevesinin cihaz parçalarında (bezel, island) ve tasarım galerisinin palet örneklerinde geçer.
- Renk ve yazı temadan okunur:

  ```dart
  final scheme = ColorScheme.of(context);   // primary, onPrimary, error, errorContainer, primaryContainer, surface
  final colors = context.appColors;         // textTitle, textSecondary, card, border, accent ...
  final semantic = context.semanticColors;  // success, warning, info
  final text = context.textStyles;          // title18, caption12, label14 ...

  Text(name, style: text.title18);
  Text(pay, style: text.title18.copyWith(color: semantic.success));
  ```

- Hata rengi `scheme.error` / `errorContainer`'dan gelir; `SemanticColors`'ta hata yoktur.
- Yeni bir rol gerekiyorsa `AppColors`'a eklenir ve iki temada da `AppPalette`'te değer alır.
- Tema değiştirme: `ref.read(themeModeControllerProvider.notifier).setMode(AppThemeMode.dark)`.
- Koyu temanın referans tasarımı yoktur; renkleri case paletindeki koyu token'lardan seçilmiştir (zemin `strong`, kart `slate-700`, kenarlık `slate-600`, vurgu metni `primary-light`, seçili kart `primary-darkest`). Case dışında renk eklenmez; testler iki temanın da yalnız `colors.xml` renklerini kullandığını doğrular. Tek istisna koyu temanın kırmızısıdır (`AppPalette.errorOnDark`, case kırmızısının %30 beyaza karıştırılmış hâli); test bu türetmeyi de doğrular.

### Kontrast (WCAG 2.1 AA)

- Koyu temada metin/zemin çiftlerinin hepsi 4,5:1'i sağlar ve bu testle korunur. Acil geri sayım ve detay hatası 12 px olduğundan kalın olmaları onları "büyük metin" yapmaz; case kırmızısı koyu kartta 3,6:1 kaldığı için koyu tema açık kırmızı `errorOnDark` kullanır (5,0:1).
- Açık tema referansla birebir kalır; case renklerinin bazıları 4,5:1'in altındadır ve değiştirilmedi: beyaz üzerinde yeşil ücret (2,9), pasif talep sekmesi `soft` (2,4), ücret satırındaki turuncu (2,6), `gray-500` açıklamalar (4,2), `errorSoft` üzerinde kırmızı (3,2), beyaz kartta kırmızı acil geri sayım (3,7).

### Yazı

| Dosya | İçerik |
|---|---|
| [tokens/app_text_styles.dart](lib/core/theme/tokens/app_text_styles.dart) | Case'in 10 yazı stili: boyut / ağırlık / satır yüksekliği, harf aralığı; renksiz |
| [app_text_theme.dart](lib/core/theme/app_text_theme.dart) | Aynı stiller, temanın varsayılan renkleriyle (`context.textStyles`) |
| [tokens/](lib/core/theme/tokens/) `app_spacing`, `app_radius`, `app_sizes` | Boşluk, köşe yarıçapı ve boyutlar: `AppSpacing.page`, `AppRadius.card`, `AppSizes.avatar` |
| [tokens/app_shadows.dart](lib/core/theme/tokens/app_shadows.dart) | Kart, buton, sekme ve telefon çerçevesi gölgeleri |

- Satır yüksekliği case'teki piksel değerinden çevrilir (18/24 → `height: 24 / 18`).
- Farklı kullanım için yalnız renk değiştirilir: `text.title16Semibold.copyWith(color: semantic.success)`.
- İki tema da varsayılan fontu Urbanist yapar; tüm metinlerde `liga`/`calt` ve Material dalga efekti kapalıdır.

## Görseller ve font

- `assets/icons/`: case paketindeki 15 SVG ikon, değiştirilmeden. [AppIcon](lib/core/presentation/widgets/app_icon.dart) ikonu orijinal renginde veya tek renge boyanmış çizer; star, check, send gibi beyaz maske ikonlar kullanıldıkları yerde boyanır.
- `assets/fonts/urbanist/`: Urbanist 400, 500, 600, 700 (sürüm 1.3, [github.com/coreyhu/Urbanist](https://github.com/coreyhu/Urbanist)); lisans [OFL.txt](assets/fonts/urbanist/OFL.txt). Font uygulamayla birlikte gelir, internetten indirilmez. `liga` ve `calt` kapalı kullanılır.
- Urbanist'te ₺ işareti yok; bu karakter sistem fontuyla çizilir.
- `online.svg` içindeki çok hafif gölge (filtre) flutter_svg tarafından çizilmez; beyaz halka ve yeşil nokta görünür.
- Aday fotoğrafları ve işletme logoları uygulamaya gömülmez; API'nin `/assets/...` adreslerinden yüklenir.
- `assets/branding/vardigo_splash_logo.png`: Vardigo logosu. [BrandLogo](lib/core/presentation/widgets/brand_logo.dart) bunu rol ekranında ve açılışta çizer. iOS/Android uygulama ikonları ve yerel açılış görselleri bu dosyadan [tool/export_branding.swift](tool/export_branding.swift) ile üretilir (macOS, `apps/mobile` içinde: `swift -module-cache-path /tmp/vardigo-branding-modules tool/export_branding.swift`).
- Açılış: yerel açılış ekranı ilk kareye kadar statik logoyu gösterir; ardından [StartupBranding](lib/app/startup/startup_branding.dart) 1,5 sn'lik bir kez oynayan logo geçişi yapar. Router altında hazır kalır, yani deep link ve rol yönlendirmesi beklemez; sistemde animasyonlar kapalıysa geçiş atlanır.

[Tasarım galerisi](lib/features/design_gallery/presentation/pages/design_preview_screen.dart) (debug derlemede rol ekranından açılır): font ağırlıkları, Türkçe karakterler, 10 yazı stili, ana renkler, tüm ikonlar ve referanstaki kullanım örnekleri.

## Telefon çerçevesi

Case, referanstaki gibi siyah bezel ve Dynamic Island'lı bir telefon çerçevesi istiyor. `REFERENCE_FRAME=true` ile uygulama [PhoneFrame](lib/app/reference_frame/phone_frame.dart) içinde açılır:

- Dış kutu 390×844, bezel 11 px, köşe yarıçapı 54 / 44, gölge ve 1 px iç çizgi.
- Status bar: solda 9:41, ortada 126×37 Dynamic Island ve lens, sağda sinyal/Wi-Fi/batarya (`levels.svg`). En altta 135×5 home pill.
- Ekranlar 368×822 iç alanda çizilir. Status bar (54) ve home alanı (30) ekranlara güvenli alan olarak verilir; ekranlar `SafeArea` ile referanstaki yerleşime oturur, çerçeve için ayrı kod içermez.
- Ekran çerçeveden küçükse çerçeve tek oranla küçültülür.
- Ölçüler `AppFrame` token'larındadır ([app_frame.dart](lib/core/theme/tokens/app_frame.dart)).

Bayrak olmadan uygulama cihazın kendi ekran kenarlarını ve güvenli alanını kullanır; sahte saat veya çentik çizilmez.

Referansta Dynamic Island yerine çentik görünür; case metni Dynamic Island istediği ve token'larda island ölçüleri verildiği için island çizildi.

## Klasörler

Kod teknik katmana göre değil, iş alanına (feature) göre düzenlenir; her feature kendi katmanlarını içinde taşır.

```text
lib/
├── main.dart                  # yalnız bootstrap() çağırır
├── bootstrap.dart             # ilk kareden önceki kurulum (shared_preferences, ProviderScope)
├── app/                       # uygulama seviyesi: feature'ları birbirine bağlar
│   ├── app.dart               # MaterialApp.router, tema modu
│   ├── composition_root.dart  # adaptörleri port'lara bağlayan tek yer; apiClientProvider
│   ├── router/                # go_router hub'ı (aşağıda)
│   └── reference_frame/       # 390×844 telefon çerçevesi
├── core/                      # feature bilmeyen ortak altyapı
│   ├── api/                   # ApiClient (Dio), ApiConfig, JSON okuma
│   ├── error/exceptions/      # ApiException
│   ├── l10n/                  # app_tr.arb, üretilen AppLocalizations, context.l10n
│   ├── theme/                 # tema, palet, ThemeExtension'lar, tokens/
│   └── presentation/
│       ├── widgets/           # PrimaryButton, PillTabs, AsyncListView, ErrorView ...
│       ├── pages/             # RouteErrorScreen (bilinmeyen adres)
│       ├── extensions/        # context.showAppSnackBar
│       └── failure_message/   # errorText: hata → Türkçe mesaj
├── features/
│   ├── session/               # demo giriş, rol seçimi
│   ├── candidates/            # eşleşen personeller (işveren)
│   ├── offers/                # görüşme talepleri (iş arayan)
│   ├── appearance/            # tema seçimi
│   └── design_gallery/        # yalnız presentation: debug tasarım galerisi
└── gen/                       # FlutterGen çıktısı (asset, renk, font)
```

Bir feature'ın içi:

```text
features/offers/
├── domain/
│   ├── entities/              # Offer, OfferList, OfferStatus, OfferTab, OfferSort
│   └── repositories/          # IOffersRepository (port)
├── application/
│   ├── offers_repository_provider.dart   # port provider'ı; composition root bağlar
│   ├── offers_revision.dart   # her yanıttan sonra artar; listeler bunu izleyip yenilenir
│   └── usecases/              # GetOffers, GetOfferDetail, RespondToOffer
├── infrastructure/
│   └── repositories/          # OffersRepositoryImpl (adaptör: Dio + JSON → entity)
└── presentation/
    ├── controllers/           # Riverpod: OffersController (use case'leri çağırır), OffersState, OfferQuery, RespondResult
    ├── pages/                 # OffersScreen: provider'ları okur, parçaları birleştirir
    ├── routes/                # offers_routes.dart (part of app_router.dart)
    ├── extensions/            # enum → Türkçe metin (sekme, sıralama, boş liste)
    └── widgets/               # başlık, sekmeler, card/ (özet, butonlar, detay, geri sayım)
```

Kurallar:

- **Bağımlılık yönü (hexagonal):** `presentation → application → domain ← infrastructure`. Oklar yalnız içeri bakar:
  - `domain`: entity'ler ve `I…Repository` port'ları; yalnız kendi domain'ini, Dart'ı ve `flutter/foundation`'ı import eder. Serileştirme yoktur.
  - `application`: use case sınıfları (`GetCandidates`, `SendInterviewRequests`, `RespondToOffer`, `Login`...) ve port provider'ları. Yalnız domain'i import eder; Riverpod burada bağımlılık bağlama aracıdır (kurallardaki `@injectable`'ın karşılığı).
  - `infrastructure`: `…RepositoryImpl` adaptörleri port'ları uygular, JSON'u okur. Application, presentation ve `app/`'i bilmez.
  - `presentation`: controller'lar use case çağırır; infrastructure'a ve composition root'a dokunmaz.
  - Port provider'ları varsayılan olarak hata fırlatır; somut adaptörleri yalnız `app/composition_root.dart` bağlar (`appAdapters`, testlerde sahteler). `core/` hiçbir feature'ı ve `app/`'i import etmez.
- **Denetim:** [test/architecture/layer_rules_test.dart](test/architecture/layer_rules_test.dart) `lib/` altındaki her import'u bu kurallara göre kontrol eder ve CI'da çalışır; ihlalde dosyayı, import'u ve kuralı yazar.
- **Adlar:** port'lar `I` önekiyle (`IOffersRepository`, `i_offers_repository.dart`), adaptörler `Impl` sonekiyle (`OffersRepositoryImpl`).
- **Dosya başına bir public tip**, dosya adı sınıf adının snake_case hâli. İstisna: `SubmitResult` ve `RespondResult` `sealed` aileleri; Dart alt sınıfların aynı dosyada olmasını şart koşar.
- Domain Flutter UI, Dio veya Riverpod bilmez; widget HTTP isteği yapmaz. Provider'ları sayfa okur; `widgets/` altındakiler değer ve callback alır. İstisnalar: sunucu adresinden görsel URL'si kuran avatar/logo ve açılınca yüklenen talep detayı.
- Bir parça yalnız bir feature'da kullanılıyorsa o feature'da kalır; iki feature kullanıyorsa `core/presentation/widgets/`'e taşınır. İki ekranın sekme tasarımı aynı `PillTabs` bileşenini farklı `PillTabsStyle` ile kullanır.
- Kurallardan bilerek alınmayanlar: Bloc ve getIt/injectable (proje Riverpod kullanır), `fpdart` `Either`/`FutureResult`, Failure tipleri ve DTO/mapper'lar (repository'ler JSON'u doğrudan entity'ye çevirir, hatalar `ApiException` olarak taşınır), build flavor'ları (tek ortam).

## Gezinme (go_router)

Gezinme [go_router](https://pub.dev/packages/go_router) ve tip güvenli route'lar ([go_router_builder](https://pub.dev/packages/go_router_builder)) ile yapılır. `Navigator.push` kullanılmaz.

```text
lib/app/router/
├── app_router.dart          # appRouterProvider (Riverpod), part'lar, koruma ve oturum kuralı
├── app_router.g.dart        # üretilen: $appRoutes, route mixin'leri (depoya dahil)
├── route_definitions.dart   # yol ve ad sabitleri
├── route_guard.dart         # guardRedirect, requiredRoleFor, homeLocationFor
features/*/presentation/routes/*_routes.dart  # route sınıfları (part of app_router.dart)
core/presentation/pages/route_error_screen.dart  # bilinmeyen adres sayfası
```

| Adres | Ekran | Kim açabilir |
|---|---|---|
| `/` (`?from=...`) | Rol seçimi (Hoş geldin) | Herkes |
| `/candidates?tab=perfect\|similar&sort=recommended\|near\|rating` | Eşleşen Personeller | İşveren |
| `/offers?tab=pending\|answered\|expired&sort=recommended\|expiring\|pay` | Görüşme Talepleri | İş arayan |
| `/gallery` | Tasarım galerisi | Yalnız debug derleme |

- **Kullanım:** `const OffersRoute(tab: OfferTab.answered).push(context)`, `const RoleSelectRoute().go(context)`, geri için `context.pop()`.
- **Koruma:** Başka hesabın ekranına giden adres rol seçimine `?from=<adres>` ile döner. Doğru hesap seçilince o adrese devam edilir, diğer hesap seçilirse kendi ekranı açılır. Koruma her `go` ve `push`'ta çalışır.
- **Oturum:** Başka bir ekrandan rol seçimine dönmek (geri tuşu, koruma ya da bağlantı) demo oturumunu kapatır. Bu kural tek yerde, `appRouterProvider` içindedir.
- **Query parametreleri:** `tab` ve `sort` ekranın açıldığı sekme ve sıralamadır; sonraki sekme değişiklikleri adrese yazılmaz. Geçersiz değer (`?tab=xyz`) varsayılana düşer.
- **Bilinmeyen adres:** "Sayfa bulunamadı" ve "Rol seçimine dön".
- **Deep link:** iOS ve Android `vardigo://app/<adres>` bağlantılarını uygulamaya iletir. Simülatörde deneme:

  ```bash
  xcrun simctl openurl booted "vardigo://app/candidates?tab=similar"
  adb shell am start -a android.intent.action.VIEW -d "vardigo://app/offers?tab=answered"
  ```

- Route eklendiğinde veya değiştiğinde: `dart run build_runner build --delete-conflicting-outputs`. CI, `app_router.g.dart`'ın güncel olduğunu kontrol eder.
- Alınmayanlar: `getIt`/`injectable` (proje Riverpod kullanıyor) ve alt gezinme çubuğu (`StatefulShellRoute`); sekmeler ekranların içinde, ekranlar arasında değil.

## Ekranlar

1. **Rol seçimi (Hoş geldin):** Vardigo logosu, İşveren veya İş arayan; seçilen rolle `POST /auth/login` yapılır, giriş sürerken iki kart da kilitlenir. Başka bir ekrandan buraya dönünce oturum kapanır. Açık/koyu tema sağ üstteki anahtarla seçilir. Debug derlemede buradan tasarım galerisi de açılır.
2. **Eşleşen Personeller (işveren):** sekmeler (`tab=perfect|similar`), sıralama düğmesi (Önerilen → En Yakın → Puan), çoklu seçim ve "Görüşme Talebi Gönder (N)".
   - İlk açılışta API'nin `selectedHint` değeri kadar ilk aday (Merve) seçili gelir; bu bir kez uygulanır.
   - Seçim sekmeler arasında korunur; sayı iki sekmedeki seçimlerin toplamıdır.
   - Gönderim sırasında sekme, sıralama ve seçim kilitlenir. Başarıda gönderilenler seçimden çıkar; 409 gibi hatalarda backend mesajı gösterilir ve seçim korunur.
   - Sunucudan yanıt gelmezse otomatik tekrar gönderilmez; "doğrulanamadı" uyarısı gösterilir.
   - Yükleniyor, boş liste ve hata + "Tekrar dene" durumları vardır; liste aşağı çekilerek yenilenir.
3. **Görüşme Talepleri (iş arayan):** Bekleyen / Cevaplanan / Süresi Dolan sekmeleri (`status=pending|answered|expired`), sıralama (Önerilen → Süresi Yakın → Ücret).
   - İlgileniyorum / İlgilenmiyorum talebi kabul veya ret eder; talep Cevaplanan sekmesine geçer ve karar kalıcıdır. Süresi dolmuş veya daha önce yanıtlanmış talepte backend'in mesajı gösterilir ve liste yenilenir.
   - "Detayları Gör" kartın altında detay endpoint'inden gelen şehir ve şube notunu, ücret ve saati gösterir.
   - Geri sayım `expiresAt` ile cihazda hesaplanır ve 30 saniyede bir güncellenir; 6 saatten az kalınca kırmızıya döner (referanstaki ilk kart). Sayaç sıfırlanınca ve uygulama arka plandan dönünce liste sunucudan yenilenir.
   - Cevaplanan ve süresi dolan kartlarda buton ve sayaç yerine durum etiketi vardır.

### Görsel testler (golden)

[test/goldens/](test/goldens/) iki case ekranını açık ve koyu temada 390×844'te (iPhone güvenli alanıyla, 2× piksel) çizer ve kayıtlı PNG'lerle karşılaştırır:

- Veri temiz seed'den alınmış gerçek yanıtlardır (`candidates.json`, `offers_seed.json`); saat seed anına sabittir, sayaçlar 21 sa 32 dk / 18 sa 0 dk okur.
- Fotoğraf ve logolar backend'in kendi dosyalarıdır (`apps/api/public/assets`), ağ kullanılmaz.
- Yazı gerçek Urbanist'tir; Urbanist'te olmayan ₺ için Flutter SDK'daki Roboto yedek font olarak yüklenir (cihazda sistem fontu bu işi görür). Font yükleme yalnız bu klasörü etkiler (`test/goldens/flutter_test_config.dart`); diğer testler Flutter'ın test fontuyla çalışır.
- PNG'ler macOS'ta üretilir; CI da onları macOS'ta (`Mobile goldens` işi) kontrol eder, çünkü Linux yazıyı farklı çizer. Ubuntu'daki `Mobile` işi bunları `--exclude-tags golden` ile atlar. Başarısızlıkta fark görüntüleri `golden-failures` artifact'ı olarak saklanır.
- Aynı platformdaki küçük çizim farkları için piksellerin %0,5'ine kadar fark kabul edilir; 2 px'lik bir boşluk değişikliği bile ~%6 fark verir.
- Goldenlar referans PNG'lerin kopyası değildir; aşağıdaki farklar bilerek korunur. Görevleri, onaylanmış görünümün sonradan bozulmasını yakalamaktır.

### Referansla farklar

- Referansta başlık sayıları 26 / 16; uygulama API'nin hesapladığı sayıları gösterir (temiz seed'de 6 / 6). Golden, fixture'daki ilk dört adayı (score sırasıyla Merve, Elif, Ferhat, Burak) çizer.
- Case'te 4 fotoğraf var; seed'e eklenen 8 aday bunları tekrar kullanır.
- Case paketindeki fotoğraf dosyaları referans görseldeki kişilerle eşleşmiyor (ör. `merve.png` referansta "Ayşe K." kartındaki fotoğraf). Seed eşlemesi korunur.
- Puan yıldızı referansta daha sarı görünür; spesifikasyondaki `#FA7319` kullanılır.
- Görüşme Talepleri başlığındaki sayı gerçek bekleyen sayısıdır (`pendingCount`, temiz seed'de 3); referanstaki 12 sabit etikettir.
- Talep logoları ve ücretleri seed'deki gibidir (Garson 45.000 / Barista 38.000 / Komi 32.000); referanstaki üç "Garson ₺1.500" kartı temsili tasarımdır.
- Spesifikasyon Görüşme Talepleri başlığını ortada tarif eder; referans görsele uyularak sola, geri butonunun yanına hizalandı.

## Durum

- iOS simülatöründe (iPhone 17 Pro) iki case ekranı ve rol ekranı gerçek backend'le, çerçeveli ve çerçevesiz denendi.
- Android: debug APK derleniyor; birleşmiş manifest'te `INTERNET` izni ve debug için şifresiz yerel trafik var. Bu makinede Android emülatörü olmadığı için emülatörde çalıştırılmadı; emülatörde API adresi otomatik `10.0.2.2:3000` olur.
