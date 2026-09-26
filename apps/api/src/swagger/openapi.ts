/** OpenAPI description served by Swagger UI at /api/docs. Keep it in step with the routes. */

const errorResponse = (description: string, code: string, message: string) => ({
  description,
  content: {
    "application/json": {
      schema: { $ref: "#/components/schemas/ErrorEnvelope" },
      example: { ok: false, error: { code, message } },
    },
  },
});

const unauthorized = errorResponse("Token yok, geçersiz ya da rol yanlış", "ROLE_NOT_ALLOWED", "Bu işlem için yetkiniz yok");

const ok = (description: string, data: object, example: unknown) => ({
  description,
  content: {
    "application/json": {
      schema: {
        type: "object",
        required: ["ok", "data"],
        properties: { ok: { type: "boolean", const: true }, data },
      },
      example: { ok: true, data: example },
    },
  },
});

const offerExample = {
  id: "o_garson",
  title: "Garson",
  place: "Zarif Cheff Restaurant",
  pay: "45.000",
  logo: "/assets/logos/zarif.svg",
  district: "Kadıköy",
  when: "16 Ağu · 12:00 - 16:00",
  status: "pending",
  remain: "21 saat 32 dakika",
  expiresAt: "2026-09-27T07:03:00.000Z",
};

export const openApiDocument = {
  openapi: "3.1.0",
  info: {
    title: "Vardigo API",
    version: "0.1.0",
    description: [
      "İki ekranlı case için REST API.",
      "",
      "**Deneme:** Önce **Authorize** düğmesine `dev-employer` (işveren) veya `dev-worker` (iş arayan) yazın.",
      "Token'lar case gereği sabit demo değerleridir.",
      "",
      "Tüm yanıtlar `{ ok: true, data }` ya da `{ ok: false, error: { code, message } }` biçimindedir.",
    ].join("\n"),
  },
  servers: [{ url: "/api" }],
  tags: [
    { name: "Sistem" },
    { name: "Auth" },
    { name: "Adaylar", description: "İşveren" },
    { name: "Talepler", description: "İşveren gönderir, iş arayan görür" },
  ],
  components: {
    securitySchemes: {
      bearer: { type: "http", scheme: "bearer", description: "`dev-employer` veya `dev-worker`" },
    },
    schemas: {
      ErrorEnvelope: {
        type: "object",
        required: ["ok", "error"],
        properties: {
          ok: { type: "boolean", const: false },
          error: {
            type: "object",
            required: ["code", "message"],
            properties: { code: { type: "string" }, message: { type: "string" } },
          },
        },
      },
      Candidate: {
        type: "object",
        required: ["id", "name", "rating", "attend", "km", "photo", "online", "perfect", "score"],
        properties: {
          id: { type: "string", example: "w_merve" },
          name: { type: "string", example: "Merve Y." },
          rating: { type: "string", example: "4.9" },
          attend: { type: "string", example: "%100 katılım" },
          km: { type: "string", example: "4.9 km" },
          photo: { type: "string", example: "/assets/photos/merve.png" },
          online: { type: "boolean" },
          perfect: { type: "boolean", description: "score >= 80" },
          score: { type: "integer", example: 92 },
        },
      },
      Offer: {
        type: "object",
        required: ["id", "title", "place", "pay", "logo", "district", "when", "status", "remain", "expiresAt"],
        properties: {
          id: { type: "string" },
          title: { type: "string" },
          place: { type: "string" },
          pay: { type: "string", example: "45.000" },
          logo: { type: "string" },
          district: { type: "string" },
          when: { type: "string" },
          status: { type: "string", enum: ["pending", "accepted", "rejected", "expired"] },
          remain: { type: "string", example: "21 saat 32 dakika" },
          expiresAt: { type: "string", format: "date-time" },
        },
      },
    },
  },
  paths: {
    "/health": {
      get: {
        tags: ["Sistem"],
        summary: "Sunucu ayakta mı",
        responses: { 200: ok("Çalışıyor", { type: "object" }, { status: "up" }) },
      },
    },
    "/auth/login": {
      post: {
        tags: ["Auth"],
        summary: "Demo hesabıyla giriş",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["role"],
                properties: { role: { type: "string", enum: ["employer", "worker"] } },
              },
              example: { role: "employer" },
            },
          },
        },
        responses: {
          200: ok("Token", { type: "object" }, { token: "dev-employer", role: "employer" }),
          400: errorResponse("role geçersiz", "VALIDATION_ERROR", "role alanı 'employer' veya 'worker' olmalı"),
        },
      },
    },
    "/candidates": {
      get: {
        tags: ["Adaylar"],
        summary: "Eşleşen adaylar (işveren)",
        security: [{ bearer: [] }],
        parameters: [
          {
            name: "tab",
            in: "query",
            description: "`perfect`: score ≥ 80, `similar`: score < 80. Boşsa hepsi.",
            schema: { type: "string", enum: ["perfect", "similar"] },
          },
          {
            name: "sort",
            in: "query",
            description: "`recommended`: score azalan, `near`: km artan, `rating`: puan azalan",
            schema: { type: "string", enum: ["recommended", "near", "rating"], default: "recommended" },
          },
        ],
        responses: {
          200: ok(
            "Aday listesi",
            {
              type: "object",
              properties: {
                totalPerfect: { type: "integer", description: "Tasarımdaki sabit etiket" },
                totalSimilar: { type: "integer", description: "Tasarımdaki sabit etiket" },
                selectedHint: { type: "integer" },
                candidates: { type: "array", items: { $ref: "#/components/schemas/Candidate" } },
              },
            },
            {
              totalPerfect: 26,
              totalSimilar: 16,
              selectedHint: 1,
              candidates: [
                {
                  id: "w_merve",
                  name: "Merve Y.",
                  rating: "4.9",
                  attend: "%100 katılım",
                  km: "4.9 km",
                  photo: "/assets/photos/merve.png",
                  online: true,
                  perfect: true,
                  score: 92,
                },
              ],
            },
          ),
          400: errorResponse("tab veya sort geçersiz", "VALIDATION_ERROR", "tab şunlardan biri olmalı: perfect, similar"),
          401: unauthorized,
        },
      },
    },
    "/offers": {
      post: {
        tags: ["Talepler"],
        summary: "Seçilen adaylara görüşme talebi (işveren)",
        description: "Talepler ya hepsi birlikte oluşturulur ya da hiçbiri.",
        security: [{ bearer: [] }],
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                required: ["workerIds"],
                properties: { workerIds: { type: "array", items: { type: "string" }, minItems: 1, maxItems: 100 } },
              },
              example: { workerIds: ["w_merve", "w_derya"] },
            },
          },
        },
        responses: {
          201: ok("Oluşturuldu", { type: "object" }, {
            created: [
              { id: "o_…", workerId: "w_merve", status: "pending" },
              { id: "o_…", workerId: "w_derya", status: "pending" },
            ],
          }),
          400: errorResponse(
            "Boş seçim (EMPTY_SELECTION), tekrar eden id (DUPLICATE_WORKER_IDS) veya bozuk gövde (VALIDATION_ERROR)",
            "EMPTY_SELECTION",
            "En az bir personel seçin",
          ),
          401: unauthorized,
          404: errorResponse("Bilinmeyen aday", "CANDIDATE_NOT_FOUND", "Personel bulunamadı: w_x"),
          409: errorResponse("Adayın bekleyen talebi var", "OFFER_PENDING_EXISTS", "Seçilen personel için açık teklif var: w_merve"),
        },
      },
      get: {
        tags: ["Talepler"],
        summary: "Gelen talepler (iş arayan)",
        security: [{ bearer: [] }],
        parameters: [
          {
            name: "status",
            in: "query",
            description: "`answered` = kabul + ret",
            schema: { type: "string", enum: ["pending", "answered", "expired"], default: "pending" },
          },
        ],
        responses: {
          200: ok(
            "Talep listesi",
            {
              type: "object",
              properties: {
                pendingCount: { type: "integer", description: "Gerçek bekleyen sayısı" },
                pendingCountLabel: { type: "integer", description: "Tasarımdaki sabit etiket" },
                offers: { type: "array", items: { $ref: "#/components/schemas/Offer" } },
              },
            },
            { pendingCount: 3, pendingCountLabel: 12, offers: [offerExample] },
          ),
          400: errorResponse("status geçersiz", "VALIDATION_ERROR", "status şunlardan biri olmalı: pending, answered, expired"),
          401: unauthorized,
        },
      },
    },
    "/offers/{id}": {
      get: {
        tags: ["Talepler"],
        summary: "Talep detayı (iş arayan)",
        security: [{ bearer: [] }],
        parameters: [{ name: "id", in: "path", required: true, schema: { type: "string" }, example: "o_garson" }],
        responses: {
          200: ok(
            "Talep",
            {
              allOf: [
                { $ref: "#/components/schemas/Offer" },
                { type: "object", properties: { city: { type: "string" }, note: { type: "string" } } },
              ],
            },
            { ...offerExample, city: "İstanbul", note: "Şube: Sinanpaşa Mah." },
          ),
          401: unauthorized,
          404: errorResponse("Talep yok", "OFFER_NOT_FOUND", "Teklif bulunamadı"),
        },
      },
    },
  },
};
