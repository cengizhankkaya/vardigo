/**
 * Runs the case "MİNİMUM TEST" against a running server.
 * Usage: npm run db:reset && npm run dev, then in another terminal: npm run smoke
 */
const base = process.env.API_URL ?? "http://127.0.0.1:3000/api";

type Envelope = { ok: boolean; data?: any; error?: { code: string; message: string } };

async function call(method: string, path: string, token?: string, body?: unknown): Promise<[number, Envelope]> {
  const res = await fetch(base + path, {
    method,
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
      ...(body ? { "Content-Type": "application/json" } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  return [res.status, (await res.json()) as Envelope];
}

function check(step: string, ok: boolean, detail: string): void {
  console.log(`${ok ? "✓" : "✗"} ${step}: ${detail}`);
  if (!ok) {
    process.exitCode = 1;
    throw new Error(step);
  }
}

async function main() {
  console.log(`API: ${base}\n`);

  const [, employer] = await call("POST", "/auth/login", undefined, { role: "employer" });
  const [, candidates] = await call("GET", "/candidates", employer.data.token);
  const names = candidates.data.candidates.map((c: { name: string }) => c.name);
  check("1. İşveren adayları görür", names.length === 4, `${names.length} kişi (${names.join(", ")})`);

  const [sentStatus, sent] = await call("POST", "/offers", employer.data.token, { workerIds: ["w_merve", "w_derya"] });
  if (sent.error?.code === "OFFER_PENDING_EXISTS") {
    console.log("\nMerve/Derya'nın bekleyen talebi zaten var. Önce `npm run db:reset` çalıştırıp sunucuyu yeniden başlatın.");
  }
  check("2. Merve + Derya'ya talep", sentStatus === 201, `${sentStatus} ${sent.error?.code ?? "created " + sent.data.created.length}`);
  const [merveId, deryaId] = sent.data.created.map((o: { id: string }) => o.id);

  const [, worker] = await call("POST", "/auth/login", undefined, { role: "worker" });
  const [, pending] = await call("GET", "/offers?status=pending", worker.data.token);
  const pendingIds: string[] = pending.data.offers.map((o: { id: string }) => o.id);
  check(
    "3. İş arayan talepleri görür",
    pendingIds.includes(merveId) && pendingIds.includes(deryaId) && pendingIds.length >= 5,
    `${pendingIds.length} bekleyen (yeni 2 + seed)`,
  );

  const [acceptStatus] = await call("POST", `/offers/${merveId}/accept`, worker.data.token);
  const [rejectStatus] = await call("POST", `/offers/${deryaId}/reject`, worker.data.token);
  check("4. Biri kabul, biri ret", acceptStatus === 200 && rejectStatus === 200, `accept ${acceptStatus}, reject ${rejectStatus}`);

  const answeredMine = async () => {
    const [, answered] = await call("GET", "/offers?status=answered", worker.data.token);
    return answered.data.offers
      .filter((o: { id: string }) => o.id === merveId || o.id === deryaId)
      .map((o: { status: string }) => o.status)
      .join(", ");
  };
  const answered = await answeredMine();
  check("5. Cevaplananlar", answered === "accepted, rejected", answered);

  const again = await answeredMine();
  check("6. Yenileyince aynı durum", again === answered, again);

  console.log("\nSunucu yeniden başlatıldıktan sonra da kalıcılığı görmek için: sunucuyu durdurup açın ve");
  console.log(`curl "${base}/offers?status=answered" -H "Authorization: Bearer dev-worker"`);
}

main().catch((error: unknown) => {
  if (error instanceof TypeError) {
    console.error(`\nSunucuya ulaşılamadı (${base}). Önce başka bir terminalde \`npm run dev\` çalıştırın.`);
  }
  process.exitCode = 1;
});
