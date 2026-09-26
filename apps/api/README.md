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
| POST | `/api/offers` | İşveren: seçilen adaylara görüşme talebi |
| GET | `/api/offers` | İş arayan: talepler (sekmeye göre) |
| GET | `/api/offers/:id` | İş arayan: talep detayı |

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

## Görüşme talebi gönderme (işveren)

```bash
curl -X POST http://localhost:3000/api/offers \
  -H "Authorization: Bearer dev-employer" \
  -H "Content-Type: application/json" \
  -d '{"workerIds":["w_merve","w_derya"]}'
# 201 {"ok":true,"data":{"created":[{"id":"o_...","workerId":"w_merve","status":"pending"}, ...]}}
```

Case'te tek iş var: her talep "Garson — Zarif Cheff Restaurant", 45.000, Kadıköy, 16 Ağu 12:00 - 16:00 bilgisiyle oluşturulur ve 21 saat 32 dakika sonra süresi dolar. Case'te tek iş arayan hesabı olduğu için tüm talepler o hesabın gelen kutusuna düşer.

Talepler ya hepsi birlikte oluşturulur ya da hiçbiri oluşturulmaz.

| Durum | Yanıt |
|---|---|
| `workerIds` boş | `400 EMPTY_SELECTION` |
| Aynı id iki kez | `400 DUPLICATE_WORKER_IDS` |
| `workerIds` dizi değil, metin olmayan değer, 100'den fazla id | `400 VALIDATION_ERROR` |
| Bilinmeyen aday | `404 CANDIDATE_NOT_FOUND` |
| Adayın bekleyen talebi var | `409 OFFER_PENDING_EXISTS` |

Süresi dolmuş, kabul edilmiş veya reddedilmiş talepten sonra aynı adaya yeniden talep gönderilebilir.

## Talepleri listeleme (iş arayan)

```bash
curl "http://localhost:3000/api/offers?status=pending" -H "Authorization: Bearer dev-worker"
```

```json
{
  "ok": true,
  "data": {
    "pendingCount": 3,
    "pendingCountLabel": 12,
    "offers": [
      {
        "id": "o_garson",
        "title": "Garson",
        "place": "Zarif Cheff Restaurant",
        "pay": "45.000",
        "logo": "/assets/logos/zarif.svg",
        "district": "Kadıköy",
        "when": "16 Ağu · 12:00 - 16:00",
        "status": "pending",
        "remain": "21 saat 32 dakika",
        "expiresAt": "2026-09-27T07:03:00.000Z"
      }
    ]
  }
}
```

| `status` | Sekme | İçerik |
|---|---|---|
| `pending` (varsayılan) | Bekleyen | Yanıt bekleyen ve süresi dolmamış talepler |
| `answered` | Cevaplanan | Kabul (`accepted`) ve ret (`rejected`) edilenler |
| `expired` | Süresi Dolan | `expiresAt` anı geçmiş, yanıtlanmamış talepler |

- `remain` sunucuda hesaplanır: tam saat ve dakika, aşağı yuvarlanır; süresi dolanlarda `0 saat 0 dakika`.
- Süresi dolan bekleyen talepler her istekte önce `expired` yapılır, sonra liste ve sayı üretilir. Yanıtlanmış talepler süre geçince değişmez.
- `pendingCount` gerçek bekleyen sayısıdır. `pendingCountLabel` (12) referans tasarımdaki sabit etikettir.
- Sıralama: en yeni talep önce; aynı anda oluşturulanlar oluşturulma sırasını korur.
- İş arayan yalnız kendi gelen kutusunu görür.

`GET /api/offers/:id` aynı alanlara ek olarak `city` ve `note` döner; bulunamazsa `404 OFFER_NOT_FOUND`.

## Klasörler

- `src/app.ts`: Express uygulaması ve route bağlantıları.
- `src/server.ts`: HTTP sunucusunu başlatır.
- `src/bootstrap/`: ayarlar ve açılışta veritabanı hazırlığı.
- `src/platform/`: HTTP yanıtları, SQLite bağlantısı ve migration'lar.
- `src/modules/auth/`: demo login ve Bearer token rol kontrolü.
- `src/modules/candidates/`: aday listeleme, sekme filtresi ve sıralama.
- `src/modules/offers/`: talep oluşturma, listeleme, detay ve süre dolumu. Kabul/ret sonraki adımda eklenecek.
- `src/demo/`: case seed verisi, seed yükleyici ve reset komutu.
- `test/`: Vitest + Supertest testleri.
