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

Kod üretimiyle gelmeyen tasarım değerleri `lib/shared/design_system/` altında elle yazılmış sabitlerdir:

| Dosya | İçerik | Kullanım |
|---|---|---|
| [tokens/app_text_styles.dart](lib/shared/design_system/tokens/app_text_styles.dart) | Case'in 10 yazı stili (boyut / ağırlık / satır yüksekliği, harf aralığı, varsayılan renk) | `Text('...', style: AppTextStyles.title18)` |
| [tokens/app_dimens.dart](lib/shared/design_system/tokens/app_dimens.dart) | Boşluk, köşe yarıçapı ve boyutlar | `AppSpacing.page`, `AppRadius.card`, `AppSizes.avatar` |
| [tokens/app_shadows.dart](lib/shared/design_system/tokens/app_shadows.dart) | Kart, buton, sekme ve telefon çerçevesi gölgeleri | `BoxDecoration(boxShadow: AppShadows.card)` |
| [theme/app_theme.dart](lib/shared/design_system/theme/app_theme.dart) | Uygulama teması | `MaterialApp(theme: AppTheme.light())` |

- Satır yüksekliği case'teki piksel değerinden çevrilir (18/24 → `height: 24 / 18`).
- Rengi farklı kullanım için yalnız renk değiştirilir: `AppTextStyles.title16Semibold.copyWith(color: ColorName.green)`.
- Tema varsayılan fontu Urbanist yapar, tüm metinlerde `liga`/`calt` kapalıdır ve Material dalga efekti kapalıdır.

## Görseller ve font

- `assets/icons/`: case paketindeki 15 SVG ikon, değiştirilmeden. [AppIcon](lib/shared/design_system/components/app_icon.dart) ikonu orijinal renginde veya tek renge boyanmış çizer; star, check, send gibi beyaz maske ikonlar kullanıldıkları yerde boyanır.
- `assets/fonts/urbanist/`: Urbanist 400, 500, 600, 700 (sürüm 1.3, [github.com/coreyhu/Urbanist](https://github.com/coreyhu/Urbanist)); lisans [OFL.txt](assets/fonts/urbanist/OFL.txt). Font uygulamayla birlikte gelir, internetten indirilmez. `liga` ve `calt` kapalı kullanılır.
- Urbanist'te ₺ işareti yok; bu karakter sistem fontuyla çizilir.
- `online.svg` içindeki çok hafif gölge (filtre) flutter_svg tarafından çizilmez; beyaz halka ve yeşil nokta görünür.
- Aday fotoğrafları ve işletme logoları uygulamaya gömülmez; API'nin `/assets/...` adreslerinden yüklenir.

Uygulama şimdilik [tasarım galerisi](lib/preview/design_preview_screen.dart) ile açılır: font ağırlıkları, Türkçe karakterler, 10 yazı stili, ana renkler, tüm ikonlar ve referanstaki kullanım örnekleri.

## Klasörler

- `lib/main.dart`: giriş noktası.
- `lib/app/`: uygulama kökü; yönlendirme ve bağımlılık bağlantıları.
- `lib/core/`: ağ, hata ve saat gibi ortak altyapı.
- `lib/shared/design_system/`: renk, tipografi, tema ve ortak bileşenler.
- `lib/features/`: session, candidates ve offers.
- `lib/preview/`: tasarım galerisi ve case'in 390×844 telefon çerçevesi görünümü.

Feature'lar presentation/application/domain/data sınırlarıyla büyür. Domain Flutter UI, Dio veya Riverpod bilmez; widget HTTP isteği yapmaz.

## Durum

Tasarım galerisi iOS simülatöründe (iPhone 17 Pro) açılıyor. Android henüz denenmedi.
