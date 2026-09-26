# Vardigo

İki ekranlı case için Flutter mobil uygulama ve REST API.

**Durum:**

| Parça | Durum |
|---|---|
| Backend | Tamamlandı: case'teki tüm endpoint'ler, SQLite kalıcılığı, Swagger, 144 test |
| Mobil | Tamamlandı: iki case ekranı (Eşleşen Personeller, Görüşme Talepleri), demo rol seçimi, 390×844 telefon çerçevesi, 95 test |

## 5 dakikada çalışan demo

Gereksinim: Node.js 24 veya üstü, Flutter 3.47 ve açık bir iOS simülatörü veya Android emülatörü.

```bash
./demo.sh --as employer --frame
```

Script API'yi başlatır (ilk seferde `npm ci` yapar), hazır olmasını bekler ve uygulamayı gerçek API'ye bağlı açar. Uygulamadan çıkınca API de durur.

| Seçenek | Ne yapar |
|---|---|
| (yok) | Rol seçim ekranıyla açılır |
| `--as employer` | Doğrudan Eşleşen Personeller (işveren) |
| `--as worker` | Doğrudan Görüşme Talepleri (iş arayan) |
| `--frame` | Uygulamayı referanstaki 390×844 telefon çerçevesinin (bezel, Dynamic Island, 9:41) içinde gösterir |
| diğerleri | `flutter run`'a geçer, ör. `-d emulator-5554` |

Case'in minimum akışı uygulamada:

1. `./demo.sh --as employer`: Merve seçili gelir; Benzer sekmesinden Derya'yı ekleyin, "Görüşme Talebi Gönder (2)".
2. `./demo.sh --as worker`: yeni talepler Bekleyen sekmesinde; birini kabul, birini ret edin.
3. Cevaplanan sekmesinde ikisi de görünür; uygulamayı yeniden açınca aynı kalır.

Aynı adaylara ikinci kez talep 409 verir; temiz veriyle başlamak için önce `cd apps/api && npm run db:reset`.

## Hızlı başlangıç (yalnız backend)

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
✓ 3. İş arayan talepleri görür: 5 bekleyen (yeni 2 + önceden bekleyenler)
✓ 4. Biri kabul, biri ret: accept 200, reject 200
✓ 5. Cevaplananlar: accepted, rejected
✓ 6. Yenileyince aynı durum: accepted, rejected
```

Veriyi başlangıç haline döndürmek için `npm run db:reset`.

## API özeti

Tüm yanıtlar `{ ok: true, data }` veya `{ ok: false, error: { code, message } }` biçimindedir.

| Metot | Yol | Rol | Açıklama |
|---|---|---|---|
| POST | `/api/auth/login` | — | `{ "role": "employer" \| "worker" }` → demo token |
| GET | `/api/candidates` | İşveren | Eşleşen adaylar; `tab=perfect\|similar`, `sort=recommended\|near\|rating` |
| POST | `/api/offers` | İşveren | `{ "workerIds": [...] }` → seçilen adaylara görüşme talebi |
| GET | `/api/offers` | İş arayan | Talepler; `status=pending\|answered\|expired`, `sort=recommended\|expiring\|pay` |
| GET | `/api/offers/:id` | İş arayan | Talep detayı |
| POST | `/api/offers/:id/accept` | İş arayan | İlgileniyorum |
| POST | `/api/offers/:id/reject` | İş arayan | İlgilenmiyorum |

Örnek istekler, alanlar ve hata kodları: [apps/api/README.md](apps/api/README.md) veya Swagger.

## Testler

```bash
cd apps/api
npm test           # 144 test; her test kendi geçici veritabanını kullanır
npm run typecheck

cd apps/mobile
flutter test       # 95 test; canlı API testi için apps/mobile/README.md
```

CI her push'ta backend testlerini, derleme ve smoke testini, mobil kod üretimi/format/analiz/testlerini ve uygulamanın repository'lerini gerçek sunucuya karşı çalıştırır.

Case'in altı adımlık minimum testi, sunucu yeniden başlatma dahil [apps/api/test/minimum-flow.test.ts](apps/api/test/minimum-flow.test.ts) içinde de otomatik çalışır.

## Teknoloji

- Backend: Node.js, TypeScript, Express 5, `node:sqlite`; testler Vitest + Supertest; Swagger UI.
- Mobil: Flutter / Dart, iOS ve Android; Riverpod, go_router (tip güvenli route'lar, deep link), Dio, flutter_svg, shared_preferences; açık ve koyu tema; FlutterGen (asset, renk, font) ve gen-l10n (metinler). Ayrıntı: [apps/mobile/README.md](apps/mobile/README.md).
- Paketler: backend npm, mobil Flutter pub.

## Klasörler

```text
vardigo/
├── apps/
│   ├── api/            # Backend (README, kaynak, testler, seed, görseller)
│   └── mobile/         # Flutter iOS/Android
├── .github/workflows/  # CI
├── demo.sh             # Tek komutla API + uygulama
└── SUREC.txt           # Süreç notu
```

## Case yorumları

Case paketindeki bazı bilgiler birbiriyle çelişiyor veya tanımsız; uygulanan kararlar:

- **Sekmeler:** API spesifikasyonundaki score ≥ 80 kuralı esas alındı. "%100 Eşleşme" sekmesinde Merve ve Ferhat, "Benzer" sekmesinde Derya ve Ayşe görünür. Ekran spesifikasyonundaki "ikinci sekmede aynı kartlar ters sırada" ifadesi uygulanmadı.
- **Başlık sayıları:** 26 / 16 ve bekleyen talep için 12, referans tasarımdaki sabit etiketlerdir (`totalPerfect`, `totalSimilar`, `pendingCountLabel`). Gerçek sayılar ayrı alanlarda döner: 4 aday, `pendingCount`.
- **Aday ücret satırı:** Seed'de ücret bilgisi yok; kartlardaki "Ücret beklentisi uyuşuyor/uyuşmuyor · ₺25.000 / ay" değerleri referans tasarımdan alındı (Merve ve Ayşe uyuşuyor, Derya ve Ferhat uyuşmuyor).
- **Talep sıralaması:** Referansta "Sırala: Önerilen" düğmesi var ama seçenekler tanımlı değil. Önerilen (en yeni önce), süresi en yakın biten ve ücret seçenekleri eklendi.
- **Tek iş arayan:** Case'te bir iş arayan hesabı olduğu için hangi adaya gönderilirse gönderilsin talepler o hesabın gelen kutusuna düşer.
- **Süre:** Seed'deki `USE_NOW_PLUS_21H32M` gibi süreler ilk kurulum anından hesaplanır. Yanıtlanmış talepler süre geçince `expired` olmaz.
- **Giriş:** `dev-employer` / `dev-worker` token'ları case gereği sabit ve herkese açıktır; gerçek bir kimlik doğrulama değildir. Sunucu varsayılan olarak yalnız bu bilgisayardan erişilebilir (`127.0.0.1`).

## Geliştirme

Her özellik ayrı bir branch'te küçük commit'lerle geliştirilir ve merge commit ile `main`'e birleştirilir; her adım Git geçmişinde ayrı görünür. Testler ilgili özellikle aynı commit'lerde yazılır. Süreç notu: [SUREC.txt](SUREC.txt).
