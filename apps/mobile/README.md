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

## Görseller ve font

- `assets/icons/`: case paketindeki 15 SVG ikon, değiştirilmeden. [AppIcon](lib/shared/design_system/components/app_icon.dart) ikonu orijinal renginde veya tek renge boyanmış çizer; star, check, send gibi beyaz maske ikonlar kullanıldıkları yerde boyanır.
- `assets/fonts/urbanist/`: Urbanist 400, 500, 600, 700 (sürüm 1.3, [github.com/coreyhu/Urbanist](https://github.com/coreyhu/Urbanist)); lisans [OFL.txt](assets/fonts/urbanist/OFL.txt). Font uygulamayla birlikte gelir, internetten indirilmez. `liga` ve `calt` kapalı kullanılır.
- Urbanist'te ₺ işareti yok; bu karakter sistem fontuyla çizilir.
- `online.svg` içindeki çok hafif gölge (filtre) flutter_svg tarafından çizilmez; beyaz halka ve yeşil nokta görünür.
- Aday fotoğrafları ve işletme logoları uygulamaya gömülmez; API'nin `/assets/...` adreslerinden yüklenir.

Uygulama şimdilik [tasarım galerisi](lib/preview/design_preview_screen.dart) ile açılır: font ağırlıkları, Türkçe karakterler, tüm ikonlar ve referanstaki kullanım örnekleri.

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
