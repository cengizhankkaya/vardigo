#!/usr/bin/env bash
# One-command demo: starts the API and runs the Flutter app against it.
#
#   ./demo.sh                      # role picker, on the open simulator/emulator
#   ./demo.sh --as employer        # straight to "Eşleşen Personeller"
#   ./demo.sh --as worker --frame  # "Görüşme Talepleri" inside the 390×844 phone frame
#   ./demo.sh -d emulator-5554     # anything else goes to `flutter run`
#
# The API stops when the app exits. If one is already running on :3000 it is reused.
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"
api="$root/apps/api"
mobile="$root/apps/mobile"
health="http://127.0.0.1:3000/api/health"

defines=()
flutter_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --as)
      [[ "${2:-}" == employer || "${2:-}" == worker ]] || { echo "--as employer|worker" >&2; exit 2; }
      defines+=("--dart-define=START_AS=$2")
      shift 2
      ;;
    --frame)
      defines+=("--dart-define=REFERENCE_FRAME=true")
      shift
      ;;
    *)
      flutter_args+=("$1")
      shift
      ;;
  esac
done

need() {
  command -v "$1" >/dev/null || { echo "$1 bulunamadı: $2" >&2; exit 1; }
}
need node "Node.js 24 LTS gerekli (https://nodejs.org)"
need flutter "Flutter 3.47 gerekli (https://docs.flutter.dev/get-started)"
node_major="$(node -p 'process.versions.node.split(".")[0]')"
if (( node_major < 24 )); then
  echo "Node.js 24 LTS gerekli; bu makinede $(node -v) var." >&2
  exit 1
fi
# Node 25 runs the API, but `npm ci` refuses it (vitest supports 24 and 26+).
if (( node_major == 25 )) && [[ ! -d "$api/node_modules" ]]; then
  echo "Bağımlılıklar Node 25 ile kurulamaz; Node.js 24 LTS (veya 26+) kullanın." >&2
  echo "Ör. nvm ile: nvm install 24 && nvm use 24" >&2
  exit 1
fi

api_pid=""
cleanup() {
  if [[ -n "$api_pid" ]]; then
    kill "$api_pid" 2>/dev/null || true
    wait "$api_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if curl -fs "$health" >/dev/null 2>&1; then
  echo "▸ API zaten çalışıyor: $health"
else
  echo "▸ API bağımlılıkları"
  [[ -d "$api/node_modules" ]] || (cd "$api" && npm ci --no-audit --no-fund)
  tmp="${TMPDIR:-/tmp}"
  log="$(mktemp "${tmp%/}/vardigo-api.XXXXXX")"
  echo "▸ API başlıyor (log: $log)"
  (cd "$api" && exec npm run dev) >"$log" 2>&1 &
  api_pid=$!
  for _ in $(seq 1 60); do
    curl -fs "$health" >/dev/null 2>&1 && break
    if ! kill -0 "$api_pid" 2>/dev/null; then
      echo "API başlamadı:" >&2
      tail -20 "$log" >&2
      exit 1
    fi
    sleep 0.5
  done
  curl -fs "$health" >/dev/null || { echo "API 30 saniyede açılmadı; log: $log" >&2; exit 1; }
  echo "▸ API hazır: http://localhost:3000/api  ·  Swagger: http://localhost:3000/api/docs"
fi

echo "▸ Flutter"
cd "$mobile"
flutter pub get >/dev/null
flutter run ${defines[@]+"${defines[@]}"} ${flutter_args[@]+"${flutter_args[@]}"}
