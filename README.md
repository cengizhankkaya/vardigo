# Vardigo

İki ekranlı case için Flutter mobil uygulama ve REST API.

**Durum:** Backend tamamlandı: case'teki tüm endpoint'ler, SQLite kalıcılığı, Swagger ve testler hazır. Flutter ekranları henüz geliştirilmedi.

## Hızlı başlangıç (backend)

Gereksinim: Node.js 24 veya üstü (npm ile gelir). Başka kurulum gerekmez; SQLite Node'un içinde gelir.

```bash
cd apps/api
npm install
npm run dev
```

- API: http://localhost:3000/api
- Swagger: http://localhost:3000/api/docs (Authorize'a `dev-employer` veya `dev-worker` yazın)

Case'in minimum test akışını çalışan sunucuya karşı doğrulamak için ikinci bir terminalde:

```bash
cd apps/api
npm run smoke
```

```text
✓ 1. İşveren adayları görür: 4 kişi (Merve Y., Ferhat C., Derya A., Ayşe K.)
✓ 2. Merve + Derya'ya talep: 201 created 2
✓ 3. İş arayan talepleri görür: 5 bekleyen (yeni 2 + seed)
✓ 4. Biri kabul, biri ret: accept 200, reject 200
✓ 5. Cevaplananlar: accepted, rejected
✓ 6. Yenileyince aynı durum: accepted, rejected
```

Veriyi başlangıç haline döndürmek için `npm run db:reset`. Endpoint'ler, örnek istekler ve hata kodları: [apps/api/README.md](apps/api/README.md).

## Teknoloji

- Backend: Node.js, TypeScript, Express 5, `node:sqlite`; testler Vitest + Supertest; Swagger UI.
- Mobil: Flutter / Dart (sonraki adım).
- Paketler: backend npm, mobil Flutter pub.

## Klasörler

```text
vardigo/
├── apps/
│   ├── api/            # Backend (README, kaynak, testler, seed, görseller)
│   └── mobile/         # Flutter iOS/Android (sonraki adım)
├── packages/contracts/ # İlk iskeletten kalan boş klasör
├── resources/          # İlk iskeletten kalan boş klasörler
├── scripts/
├── .github/workflows/
└── SUREC.txt           # Süreç notu
```

## Case yorumları

Case paketindeki bazı bilgiler birbiriyle çelişiyor; uygulanan kararlar:

- **Sekmeler:** API spesifikasyonundaki score ≥ 80 kuralı esas alındı. "%100 Eşleşme" sekmesinde Merve ve Ferhat, "Benzer" sekmesinde Derya ve Ayşe görünür. Ekran spesifikasyonundaki "ikinci sekmede aynı kartlar ters sırada" ifadesi uygulanmadı.
- **Başlık sayıları:** 26 / 16 ve bekleyen talep için 12, referans tasarımdaki sabit etiketlerdir (`totalPerfect`, `totalSimilar`, `pendingCountLabel`). Gerçek sayılar ayrı alanlarda döner: 4 aday, `pendingCount`.
- **Tek iş arayan:** Case'te bir iş arayan hesabı olduğu için hangi adaya gönderilirse gönderilsin talepler o hesabın gelen kutusuna düşer.
- **Süre:** Seed'deki `USE_NOW_PLUS_21H32M` gibi süreler ilk kurulum anından hesaplanır. Yanıtlanmış talepler süre geçince `expired` olmaz.
- **Giriş:** `dev-employer` / `dev-worker` token'ları case gereği sabit ve herkese açıktır; gerçek bir kimlik doğrulama değildir. Sunucu varsayılan olarak yalnız bu bilgisayardan erişilebilir (`127.0.0.1`).

## Geliştirme

Her özellik ayrı bir branch'te küçük commit'lerle geliştirilir ve PR ile `main`'e birleştirilir. Testler ilgili özellikle aynı commit'lerde yazılır (`npm test`).
