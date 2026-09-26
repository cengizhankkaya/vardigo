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

## Klasörler

- `lib/main.dart`: giriş noktası.
- `lib/app/`: uygulama kökü; yönlendirme ve bağımlılık bağlantıları.
- `lib/core/`: ağ, hata ve saat gibi ortak altyapı.
- `lib/shared/design_system/`: renk, tipografi, tema ve ortak bileşenler.
- `lib/features/`: session, candidates ve offers.
- `lib/preview/`: tasarım galerisi ve case'in 390×844 telefon çerçevesi görünümü.

Feature'lar presentation/application/domain/data sınırlarıyla büyür. Domain Flutter UI, Dio veya Riverpod bilmez; widget HTTP isteği yapmaz.

## Durum

Boş uygulama iOS simülatöründe (iPhone 17 Pro) açılıyor. Android henüz denenmedi.
