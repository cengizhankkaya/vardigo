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

## Swagger

Sunucu çalışırken tarayıcıda **http://localhost:3000/api/docs** açılır.

1. Sağ üstteki **Authorize** düğmesine `dev-employer` (işveren) veya `dev-worker` (iş arayan) yazın.
2. Bir endpoint'i açıp **Try it out**, ardından **Execute** deyin; gerçek yanıt sayfada görünür.

Token tarayıcıda hatırlanır; rol değiştirmek için Authorize'dan çıkış yapıp diğer token'ı girin. Ham OpenAPI belgesi: `/api/openapi.json` ([src/swagger/openapi.ts](src/swagger/openapi.ts)).

## Cevap zarfı

```json
{ "ok": true, "data": { "status": "up" } }
{ "ok": false, "error": { "code": "NOT_FOUND", "message": "Endpoint bulunamadı" } }
```

## Endpoint'ler

| Metot | Yol | Açıklama |
|---|---|---|
| GET | `/api/health` | Sunucu ayakta mı |
| GET | `/api/docs` | Swagger arayüzü |
| POST | `/api/auth/login` | Demo hesabı için token döner |
| GET | `/api/candidates` | İşveren: eşleşen adaylar |
| POST | `/api/offers` | İşveren: seçilen adaylara görüşme talebi |
| GET | `/api/offers` | İş arayan: talepler (sekmeye göre) |
| GET | `/api/offers/:id` | İş arayan: talep detayı |
| POST | `/api/offers/:id/accept` | İş arayan: ilgileniyorum |
| POST | `/api/offers/:id/reject` | İş arayan: ilgilenmiyorum |

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

`expectedPay` ("25.000", aylık ₺) ve `payCompatible` kartlardaki "Ücret beklentisi uyuşuyor / uyuşmuyor" satırını besler. Case seed'inde ücret bilgisi olmadığı için değerler referans tasarımdan alınmıştır ([src/demo/candidate-pay.ts](src/demo/candidate-pay.ts)).

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

## Talebi yanıtlama (iş arayan)

```bash
curl -X POST http://localhost:3000/api/offers/o_garson/accept -H "Authorization: Bearer dev-worker"
curl -X POST http://localhost:3000/api/offers/o_barista/reject -H "Authorization: Bearer dev-worker"
```

Başarıda `200` ve güncel talep döner (`status: "accepted"` veya `"rejected"`). Karar veritabanına yazılır; sayfa yenilense veya sunucu yeniden başlasa da korunur ve sonradan değiştirilemez.

| Durum | Yanıt |
|---|---|
| Talep daha önce kabul/ret edilmiş | `409 OFFER_STATE` |
| Süresi dolmuş (`expiresAt` anı dahil) | `409 OFFER_EXPIRED` "Teklifin süresi doldu"; talep `expired` olur |
| Talep yok veya başkasının | `404 OFFER_NOT_FOUND` |
| İşveren token'ı | `401 ROLE_NOT_ALLOWED` |
| Dolu gövde gönderildi | `400 VALIDATION_ERROR` |

## Case minimum testi

Case'teki altı adımlık akış [test/minimum-flow.test.ts](test/minimum-flow.test.ts) içinde otomatik çalışır (sunucu yeniden başlatma dahil). Elle denemek için:

```bash
npm run db:reset && npm run dev
# 1. işveren: 4 aday
curl http://localhost:3000/api/candidates -H "Authorization: Bearer dev-employer"
# 2. Merve + Derya'ya talep
curl -X POST http://localhost:3000/api/offers -H "Authorization: Bearer dev-employer" \
  -H "Content-Type: application/json" -d '{"workerIds":["w_merve","w_derya"]}'
# 3. iş arayan: yeni iki talep + seed'deki üç talep
curl "http://localhost:3000/api/offers?status=pending" -H "Authorization: Bearer dev-worker"
# 4. birini kabul, birini ret (id'leri 2. adımın yanıtından alın)
curl -X POST http://localhost:3000/api/offers/<merve-id>/accept -H "Authorization: Bearer dev-worker"
curl -X POST http://localhost:3000/api/offers/<derya-id>/reject -H "Authorization: Bearer dev-worker"
# 5. cevaplananlar: 2 kayıt
curl "http://localhost:3000/api/offers?status=answered" -H "Authorization: Bearer dev-worker"
# 6. sunucuyu durdurup başlatın, 5. adımı tekrarlayın: aynı sonuç
```

## Görseller ve CORS

- Aday fotoğrafları ve işletme logoları `/assets/...` altında servis edilir (`/api` ön eki yok): `http://localhost:3000/assets/photos/merve.png`, `http://localhost:3000/assets/logos/zarif.svg`. API yanıtlarındaki `photo` ve `logo` alanları bu yolları verir; istemci başına sunucu adresini ekler. Dosyalar [public/assets/](public/assets/) içindedir ve case paketinden değiştirilmeden alınmıştır.
- CORS yalnız `localhost`, `127.0.0.1` ve `[::1]` kaynaklarına (her port) açıktır. Flutter uygulaması native çalıştığı için CORS'a ihtiyaç duymaz; bu ayar tarayıcıdan yapılan denemeler içindir.

## Klasörler

- `src/app.ts`: Express uygulaması ve route bağlantıları.
- `src/server.ts`: HTTP sunucusunu başlatır.
- `src/swagger/`: OpenAPI belgesi (Swagger arayüzünün kaynağı).
- `src/bootstrap/`: ayarlar ve açılışta veritabanı hazırlığı.
- `src/platform/`: HTTP yanıtları, SQLite bağlantısı ve migration'lar.
- `src/modules/auth/`: demo login ve Bearer token rol kontrolü.
- `src/modules/candidates/`: aday listeleme, sekme filtresi ve sıralama.
- `src/modules/offers/`: talep oluşturma, listeleme, detay, kabul/ret ve süre dolumu.
- `src/demo/`: case seed verisi, seed yükleyici ve reset komutu.
- `public/assets/`: case fotoğrafları ve logoları.
- `test/`: Vitest + Supertest testleri.
