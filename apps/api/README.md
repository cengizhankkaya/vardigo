# Backend

Hedef: Node.js + TypeScript + Express, SQLite kullanan modüler monolit.

Bu commit yalnız klasörleri hazırlar. package.json, bağımlılıklar, sunucu ve endpoint'ler henüz oluşturulmadı.

- `src/bootstrap/`: yapılandırma ve somut bağımlılıkların bağlanması.
- `src/platform/`: HTTP, veritabanı, saat ve log altyapısı.
- `src/modules/`: auth, candidates ve offers; ilgili özellik geliştirildiğinde açılacak.
- `src/demo/`: case hesapları, seed ve demo alıcı eşlemesi.

Her modül domain/application/infrastructure/http sınırlarıyla büyür. Domain ve application Express veya SQLite sürücüsüne bağımlı olmaz. Modüller birbirinin iç dosyalarına erişmez.

Sonraki backend adımı: sürümleri doğrula; pnpm workspace, TypeScript ve Express başlangıcını kur; başlangıç/derleme kontrolünden sonra ayrı commit oluştur. İş kuralları ve veritabanı bundan sonraki adımlardır.
