# Vardigo

İki ekranlı case için Flutter mobil uygulama ve REST API.

**Durum:** Backend iskeleti hazır (Express + TypeScript). Mobil uygulama ve iş endpoint'leri henüz yok.

## Teknoloji

- Mobil: Flutter / Dart; sonraki adımlarda Riverpod, Dio ve flutter_svg.
- Backend: Node.js / TypeScript / Express; kalıcı veri için SQLite.
- Backend paketleri: npm; mobil bağımlılıkları: Flutter pub.

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

Backend: `cd apps/api && npm install && npm run dev` (ayrıntı: [apps/api/README.md](apps/api/README.md)). Mobil çalıştırma komutları Flutter kurulumunda eklenecek.
