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
| `HOST` | `127.0.0.1` (yalnız bu bilgisayar; aynı ağdaki telefondan erişim için `0.0.0.0`) |
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
| POST | `/api/auth/login` | Demo hesabı için token döner |
| GET | `/api/candidates` | İşveren: eşleşen adaylar |

## Giriş

SMS veya parola yok; case'teki iki sabit demo hesabı kullanılır.

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"role":"employer"}'
# {"ok":true,"data":{"token":"dev-employer","role":"employer"}}
```

`role` alanı `employer` (işveren) veya `worker` (iş arayan) olabilir. Korumalı isteklerde token `Authorization: Bearer dev-employer` başlığıyla gönderilir. Token yoksa veya geçersizse `401 UNAUTHORIZED`, başka rolün token'ı kullanılırsa `401 ROLE_NOT_ALLOWED` döner.

## Adaylar (işveren)

```bash
curl "http://localhost:3000/api/candidates?tab=perfect&sort=near" \
  -H "Authorization: Bearer dev-employer"
```

| Parametre | Değerler | Varsayılan |
|---|---|---|
| `tab` | `perfect` (score ≥ 80), `similar` (score < 80) | yok: tüm adaylar |
| `sort` | `recommended` (score azalan), `near` (km artan), `rating` (puan azalan) | `recommended` |

Geçersiz değer `400 VALIDATION_ERROR` döner. `totalPerfect` (26), `totalSimilar` (16) ve `selectedHint` (1) referans tasarımdaki sabit etiketlerdir; listedeki gerçek aday sayısı 4'tür. Eşit değerlerde seed sırası korunur.

## Klasörler

- `src/app.ts`: Express uygulaması ve route bağlantıları.
- `src/server.ts`: HTTP sunucusunu başlatır.
- `src/bootstrap/`: ayarlar ve açılışta veritabanı hazırlığı.
- `src/platform/`: HTTP yanıtları, SQLite bağlantısı ve migration'lar.
- `src/modules/auth/`: demo login ve Bearer token rol kontrolü.
- `src/modules/candidates/`: aday listeleme, sekme filtresi ve sıralama.
- `src/modules/offers/`: sonraki adımlarda eklenecek.
- `src/demo/`: case seed verisi, seed yükleyici ve reset komutu.
- `test/`: Vitest + Supertest testleri.
