# Backend

Node.js + TypeScript + Express REST API. Veri Node'un yerleşik SQLite modülüyle (`node:sqlite`) saklanır.

## Gereksinim

- Node.js 24 veya üstü
- npm

## Komutlar

```bash
cd apps/api
npm install
npm run dev        # http://localhost:3000/api, değişiklikte yeniden başlar
npm test
npm run typecheck
npm run build && npm start
npm run db:reset   # veritabanını silip seed verisiyle yeniden kurar
```

| Ortam değişkeni | Varsayılan |
|---|---|
| `PORT` | `3000` |
| `DATABASE_PATH` | `apps/api/data/vardigo.db` |

## Veritabanı

Sunucu açılırken tabloları oluşturur ve veritabanı boşsa [src/demo/seed.json](src/demo/seed.json) verisini yükler (2 hesap, 4 aday, 3 teklif). Seed yalnız bir kez yüklenir; sonraki açılışlarda kabul/ret kararları ve süreler korunur. Seed'deki `USE_NOW_PLUS_21H32M` gibi süreler ilk yükleme anına göre hesaplanır. Temiz başlangıç için `npm run db:reset` kullanılır.

## Cevap zarfı

```json
{ "ok": true, "data": { "status": "up" } }
{ "ok": false, "error": { "code": "NOT_FOUND", "message": "Endpoint bulunamadı" } }
```

## Endpoint'ler

| Metot | Yol | Açıklama |
|---|---|---|
| GET | `/api/health` | Sunucu ayakta mı |

## Klasörler

- `src/app.ts`: Express uygulaması ve route bağlantıları.
- `src/server.ts`: HTTP sunucusunu başlatır.
- `src/bootstrap/`: ayarlar ve açılışta veritabanı hazırlığı.
- `src/platform/`: HTTP yanıtları, SQLite bağlantısı ve migration'lar.
- `src/modules/`: auth, candidates ve offers; ilgili özellik geliştirildiğinde açılacak.
- `src/demo/`: case seed verisi, seed yükleyici ve reset komutu.
- `test/`: Vitest + Supertest testleri.
