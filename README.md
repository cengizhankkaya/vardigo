# Vardigo

İki ekranlı case için Flutter mobil uygulama ve REST API.

**Durum:** İlk commit yalnız depo ve klasör iskeletini oluşturur. Henüz çalıştırılabilir uygulama, paket kurulumu veya API yoktur.

## Teknoloji

- Mobil: Flutter / Dart; sonraki adımlarda Riverpod, Dio ve flutter_svg.
- Backend: Node.js / TypeScript / Express; kalıcı veri için SQLite.
- Backend paketleri: pnpm; mobil bağımlılıkları: Flutter pub.

## Klasörler

```text
vardigo/
├── apps/
│   ├── api/                 # Backend
│   └── mobile/              # Flutter iOS/Android
├── packages/contracts/     # Backend TypeScript/Zod sözleşmeleri
├── resources/
│   ├── assets/             # Case varlıkları sonraki adımda alınacak
│   ├── references/         # Orijinal ekran görüntüleri
│   ├── case/               # Orijinal brief ve specs
│   └── contracts/          # Backend/Dart JSON fixture'ları
├── scripts/
├── .github/workflows/
└── SUREC.txt
```

Boş dizinlerin Git tarafından izlenmesi için `.gitkeep` kullanılır. İlk gerçek dosya eklenince ilgili `.gitkeep` kaldırılır. Ayrıntılı feature ve katman dosyaları ihtiyaç duyulan committe oluşturulur.

## Geliştirme sırası

[Backend başlangıcı](apps/api/README.md) ve [mobil başlangıcı](apps/mobile/README.md).

Her adım tek bir işi tamamlar, ilgili kontrol yapılır ve sonra commitlenir. Case kaynakları kaynak aktarımı adımında değiştirilmeden alınır; planlar ile orijinal gereksinimler ayrı tutulur.

## Çalıştırma

Bu aşamada çalıştırma komutu yoktur. Backend ve Flutter kurulum commitlerinde gerçek komutlar, doğrulanan SDK/paket sürümleri ve lockfile'lar eklenecek. Mobil cihaz/simülatör için API adresi daha sonra açıkça belgelenecek.
