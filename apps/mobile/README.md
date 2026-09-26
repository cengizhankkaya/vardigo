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
```

## Backend bağlantısı

Uygulama backend'e `http` ile bağlanır. Varsayılan adres platforma göre seçilir:

| Nerede | Adres | Backend |
|---|---|---|
| iOS simülatörü | `http://127.0.0.1:3000` | `npm run dev` |
| Android emülatörü | `http://10.0.2.2:3000` (emülatörden bilgisayara) | `npm run dev` |
| Gerçek telefon (aynı Wi-Fi) | `flutter run --dart-define=API_ORIGIN=http://<bilgisayar-IP>:3000` | `HOST=0.0.0.0 npm run dev` |

- iOS'ta yalnız yerel ağ için `http` izni açıktır (`NSAllowsLocalNetworking`); Android'de şifresiz trafik yalnız debug derlemede açıktır.
- Katmanlar: `domain` (model + repository arayüzü) → `data` (JSON okuma + Dio ile API) → `app/providers.dart` (Riverpod ile bağlama). Ekranlar yalnız repository arayüzlerini kullanır.
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
| Metinler | `lib/l10n/app_tr.arb` | `lib/l10n/gen/` | `context.l10n.sendRequest(2)` |

Kaynak dosyayı değiştirdikten sonra:

```bash
dart run build_runner build --delete-conflicting-outputs   # assets, renkler, font (FlutterGen)
flutter gen-l10n                                           # metinler (flutter run/pub get de üretir)
```

Üretilen dosyalar depoya dahildir; CI, kaynakla uyumsuz kalırlarsa hata verir.

- **Renkler** case'in design token listesindeki adlarla tutulur (`slate-700` → `ColorName.slate700`). XML'de alfa başta yazılır: CSS `#FB37481A` → `#1AFB3748`.
- **Metinler** şimdilik yalnız Türkçe (`tr`). Yeni metin: `app_tr.arb` dosyasına anahtar ekle, `flutter gen-l10n` çalıştır, `context.l10n.anahtar` ile kullan. Yer tutuculu metinler (`{count}`) ARB'de tip bilgisiyle tanımlanır.

## Tema ve token'lar

Uygulamanın açık (referans tasarım) ve koyu teması vardır. Seçim rol ekranındaki **Görünüm: Sistem / Açık / Koyu** ile yapılır, cihazda saklanır ve uygulama yeniden açıldığında korunur.

### Yapı

```text
lib/shared/design_system/
├── tokens/                 # renksiz ölçüler: yazı boyutları, boşluk, köşe, gölge
│   ├── app_text_styles.dart
│   ├── app_dimens.dart
│   └── app_shadows.dart
└── theme/                  # tema yapılandırması (yalnız veri, durum yok)
    ├── app_palette.dart      # açık/koyu renk setleri; yalnız case paleti (ColorName)
    ├── app_colors.dart       # ThemeExtension: metin seviyeleri, yüzeyler, kenarlıklar
    ├── semantic_colors.dart  # ThemeExtension: success, warning, info
    ├── app_text_theme.dart   # ThemeExtension: case'in 10 yazı stili, temanın renkleriyle
    ├── app_theme.dart        # AppTheme.light() / AppTheme.dark()
    ├── theme_context.dart    # context.appColors / semanticColors / textStyles
    └── theme.dart            # barrel

lib/features/appearance/    # tema durumu (Riverpod)
├── domain/app_theme_mode.dart              # AppThemeMode { system, light, dark }
├── data/prefs_theme_mode_repository.dart   # shared_preferences ile saklama
├── application/theme_mode_controller.dart  # themeModeControllerProvider
└── presentation/theme_mode_picker.dart     # Görünüm seçici
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
- Koyu temanın referans tasarımı yoktur; renkleri case paletindeki koyu token'lardan seçilmiştir (zemin `strong`, kart `slate-700`, kenarlık `slate-600`, vurgu metni `primary-light`, seçili kart `primary-darkest`). Case dışında renk eklenmez; testler iki temanın da yalnız `colors.xml` renklerini kullandığını doğrular.

### Kontrast (WCAG 2.1 AA)

- Koyu temada metin/zemin çiftleri 4,5:1'i sağlar ve bu testle korunur. Tek istisna kırmızı: acil geri sayım ve detay hatası 3,6:1'dir (paletten daha açık kırmızı yok); bu, kalın/büyük metin için AA sınırı olan 3:1'in üzerindedir.
- Açık tema referansla birebir kalır; case renklerinin bazıları 4,5:1'in altındadır ve değiştirilmedi: beyaz üzerinde yeşil ücret (2,9), pasif talep sekmesi `soft` (2,4), ücret satırındaki turuncu (2,6), `gray-500` açıklamalar (4,2), `errorSoft` üzerinde kırmızı (3,2).

### Yazı

| Dosya | İçerik |
|---|---|
| [tokens/app_text_styles.dart](lib/shared/design_system/tokens/app_text_styles.dart) | Case'in 10 yazı stili: boyut / ağırlık / satır yüksekliği, harf aralığı; renksiz |
| [theme/app_text_theme.dart](lib/shared/design_system/theme/app_text_theme.dart) | Aynı stiller, temanın varsayılan renkleriyle (`context.textStyles`) |
| [tokens/app_dimens.dart](lib/shared/design_system/tokens/app_dimens.dart) | Boşluk, köşe yarıçapı ve boyutlar: `AppSpacing.page`, `AppRadius.card` |
| [tokens/app_shadows.dart](lib/shared/design_system/tokens/app_shadows.dart) | Kart, buton, sekme ve telefon çerçevesi gölgeleri |

- Satır yüksekliği case'teki piksel değerinden çevrilir (18/24 → `height: 24 / 18`).
- Farklı kullanım için yalnız renk değiştirilir: `text.title16Semibold.copyWith(color: semantic.success)`.
- İki tema da varsayılan fontu Urbanist yapar; tüm metinlerde `liga`/`calt` ve Material dalga efekti kapalıdır.

## Görseller ve font

- `assets/icons/`: case paketindeki 15 SVG ikon, değiştirilmeden. [AppIcon](lib/shared/design_system/components/app_icon.dart) ikonu orijinal renginde veya tek renge boyanmış çizer; star, check, send gibi beyaz maske ikonlar kullanıldıkları yerde boyanır.
- `assets/fonts/urbanist/`: Urbanist 400, 500, 600, 700 (sürüm 1.3, [github.com/coreyhu/Urbanist](https://github.com/coreyhu/Urbanist)); lisans [OFL.txt](assets/fonts/urbanist/OFL.txt). Font uygulamayla birlikte gelir, internetten indirilmez. `liga` ve `calt` kapalı kullanılır.
- Urbanist'te ₺ işareti yok; bu karakter sistem fontuyla çizilir.
- `online.svg` içindeki çok hafif gölge (filtre) flutter_svg tarafından çizilmez; beyaz halka ve yeşil nokta görünür.
- Aday fotoğrafları ve işletme logoları uygulamaya gömülmez; API'nin `/assets/...` adreslerinden yüklenir.

[Tasarım galerisi](lib/preview/design_preview_screen.dart) (debug derlemede rol ekranından açılır): font ağırlıkları, Türkçe karakterler, 10 yazı stili, ana renkler, tüm ikonlar ve referanstaki kullanım örnekleri.

## Telefon çerçevesi

Case, referanstaki gibi siyah bezel ve Dynamic Island'lı bir telefon çerçevesi istiyor. `REFERENCE_FRAME=true` ile uygulama [PhoneFrame](lib/preview/phone_frame.dart) içinde açılır:

- Dış kutu 390×844, bezel 11 px, köşe yarıçapı 54 / 44, gölge ve 1 px iç çizgi.
- Status bar: solda 9:41, ortada 126×37 Dynamic Island ve lens, sağda sinyal/Wi-Fi/batarya (`levels.svg`). En altta 135×5 home pill.
- Ekranlar 368×822 iç alanda çizilir. Status bar (54) ve home alanı (30) ekranlara güvenli alan olarak verilir; ekranlar `SafeArea` ile referanstaki yerleşime oturur, çerçeve için ayrı kod içermez.
- Ekran çerçeveden küçükse çerçeve tek oranla küçültülür.
- Ölçüler `AppFrame` token'larındadır ([app_dimens.dart](lib/shared/design_system/tokens/app_dimens.dart)).

Bayrak olmadan uygulama cihazın kendi ekran kenarlarını ve güvenli alanını kullanır; sahte saat veya çentik çizilmez.

Referansta Dynamic Island yerine çentik görünür; case metni Dynamic Island istediği ve token'larda island ölçüleri verildiği için island çizildi.

## Klasörler

- `lib/main.dart`: giriş noktası.
- `lib/app/`: uygulama kökü; yönlendirme ve bağımlılık bağlantıları.
- `lib/core/`: ağ, hata ve saat gibi ortak altyapı.
- `lib/shared/design_system/`: renk, tipografi, tema ve ortak bileşenler (buton, sekme, checkbox, boş/yükleniyor/hata görünümleri).
- `lib/shared/widgets/`: ekranlara ortak, Riverpod bilen parçalar: `AsyncListView` (yenilenebilir liste + yükleniyor/boş/hata) ve `showAppSnackBar`.
- `lib/features/`: session, candidates ve offers.
- `lib/preview/`: tasarım galerisi ve case'in 390×844 telefon çerçevesi görünümü.

Feature'lar presentation/application/domain/data sınırlarıyla büyür. Domain Flutter UI, Dio veya Riverpod bilmez; widget HTTP isteği yapmaz.

Presentation katmanı ekran ve widget olarak ayrılır:

```text
features/offers/presentation/
├── offers_screen.dart          # provider'ları okur, parçaları birleştirir
├── offer_labels.dart           # enum → Türkçe metin (sekme, sıralama, boş liste)
└── widgets/
    ├── offers_header.dart, offer_tabs.dart, offer_sort_row.dart
    └── card/                   # offer_card.dart ve parçaları: özet, butonlar,
                                # detay, durum etiketi, geri sayım
```

- Provider'ları ekran okur; `widgets/` altındakiler değer ve callback alır. İstisnalar yalnız sunucu adresinden görsel URL'si kuran avatar/logo ve açılınca yüklenen talep detayıdır.
- Bir parça iki feature'da kullanılıyorsa `shared/` altına taşınır; iki ekranın sekme tasarımı aynı `PillTabs` bileşenini farklı `PillTabsStyle` ile kullanır.

## Gezinme (go_router)

Gezinme [go_router](https://pub.dev/packages/go_router) ve tip güvenli route'lar ([go_router_builder](https://pub.dev/packages/go_router_builder)) ile yapılır. `Navigator.push` kullanılmaz.

```text
lib/app/router/
├── app_router.dart          # appRouterProvider (Riverpod), part'lar, koruma ve oturum kuralı
├── app_router.g.dart        # üretilen: $appRoutes, route mixin'leri (depoya dahil)
├── route_definitions.dart   # yol ve ad sabitleri
├── route_guard.dart         # guardRedirect, requiredRoleFor, homeLocationFor
└── route_error_screen.dart  # bilinmeyen adres sayfası
features/*/presentation/routes/*_route.dart   # route sınıfları (part of app_router.dart)
preview/gallery_route.dart
```

| Adres | Ekran | Kim açabilir |
|---|---|---|
| `/` (`?from=...`) | Demo hesabı seç | Herkes |
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

1. **Demo hesabı seç:** İşveren veya İş arayan; seçilen rolle `POST /auth/login` yapılır. Başka bir ekrandan buraya dönünce oturum kapanır. Görünüm (Sistem / Açık / Koyu) buradan seçilir. Debug derlemede buradan tasarım galerisi de açılır.
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

### Referansla farklar

- Referansın ilk sekmesinde 4 kişi var; API kuralı (score ≥ 80) bu sekmede 2 kişi döndürür.
- Case paketindeki fotoğraf dosyaları referans görseldeki kişilerle eşleşmiyor (ör. `merve.png` referansta "Ayşe K." kartındaki fotoğraf). Seed eşlemesi korunur.
- Puan yıldızı referansta daha sarı görünür; spesifikasyondaki `#FA7319` kullanılır.
- Görüşme Talepleri başlığındaki sayı gerçek bekleyen sayısıdır (`pendingCount`, temiz seed'de 3); referanstaki 12 sabit etikettir.
- Talep logoları ve ücretleri seed'deki gibidir (Garson 45.000 / Barista 38.000 / Komi 32.000); referanstaki üç "Garson ₺1.500" kartı temsili tasarımdır.
- Spesifikasyon Görüşme Talepleri başlığını ortada tarif eder; referans görsele uyularak sola, geri butonunun yanına hizalandı.

## Durum

- iOS simülatöründe (iPhone 17 Pro) iki case ekranı ve rol ekranı gerçek backend'le, çerçeveli ve çerçevesiz denendi.
- Android: debug APK derleniyor; birleşmiş manifest'te `INTERNET` izni ve debug için şifresiz yerel trafik var. Bu makinede Android emülatörü olmadığı için emülatörde çalıştırılmadı; emülatörde API adresi otomatik `10.0.2.2:3000` olur.
