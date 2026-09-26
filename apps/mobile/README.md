# Flutter mobil

Hedef: Flutter / Dart ile iOS ve Android. İki case ekranı burada geliştirilecek.

Bu commit yalnız klasörleri hazırlar. Flutter projesi, pubspec, platform dosyaları ve uygulama giriş dosyası henüz oluşturulmadı.

- `lib/app/`: başlangıç, composition root, yönlendirme ve lifecycle.
- `lib/core/`: yapılandırma, ağ, hata ve saat gibi ortak altyapı.
- `lib/shared/design_system/`: renk, tipografi, tema ve ortak bileşenler.
- `lib/features/`: session, candidates ve offers; ilgili özellik geliştirildiğinde açılacak.
- `lib/preview/`: asset/tema galerisi ve case referans görünümü.

Feature'lar presentation/application/domain/data sınırlarıyla büyür. Domain Flutter UI/Dio/Riverpod bilmez; widget HTTP isteği yapmaz. TypeScript şemaları Dart'a import edilmez.

Sonraki mobil adımı: Flutter/Dart ve hedef cihazı doğrula; bu dizinde yalnız Android/iOS hedefleriyle Flutter iskeletini üret; boş uygulamayı aç; analyze/derleme sonucunu kaydet ve ayrı commit oluştur. Ardından asset/font, renk/tema, galeri ve ekran adımları gelir.
