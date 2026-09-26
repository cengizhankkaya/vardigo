# Backend

Node.js + TypeScript + Express REST API. Veri için SQLite kullanılacak.

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
```

Port `PORT` ortam değişkeniyle değiştirilebilir.

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
- `src/platform/`: HTTP, veritabanı ve saat gibi altyapı.
- `src/modules/`: auth, candidates ve offers; ilgili özellik geliştirildiğinde açılacak.
- `src/demo/`: demo hesapları ve seed.
- `test/`: Vitest + Supertest testleri.
