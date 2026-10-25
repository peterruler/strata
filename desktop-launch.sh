#!/usr/bin/env bash
set -euo pipefail

URL=http://127.0.0.1:8080/
APP=/data/ai/Strata-DGX-Spark
server_pid=

fail() {
  echo "$*" >&2
  read -r -p 'Press Enter to close.' || true
  exit 1
}

browser=
for candidate in google-chrome google-chrome-stable chromium chromium-browser; do
  if command -v "$candidate" >/dev/null 2>&1; then
    browser=$candidate
    break
  fi
done
[[ -n "$browser" ]] || fail 'Chrome or Chromium is required.'

ready() { curl --fail --silent --max-time 2 "${URL}health" >/dev/null; }

if ! ready; then
  [[ -x "$APP/run-coder-iq1_m.sh" ]] || fail 'Install Strata first with bash install-strata.sh.'
  cd "$APP"
  ./run-coder-iq1_m.sh &
  server_pid=$!
  trap 'kill "$server_pid" 2>/dev/null || true' EXIT
  trap 'exit 130' INT TERM
  echo "Waiting for Strata at $URL (first startup can take several minutes)..."
  until ready; do
    kill -0 "$server_pid" 2>/dev/null || fail 'Strata stopped before becoming ready. See the output above.'
    sleep 2
  done
fi

"$browser" "$URL" >/dev/null 2>&1 &
if [[ -n "$server_pid" ]]; then
  echo 'Strata is ready. Keep this terminal open; press Ctrl+C to stop.'
  wait "$server_pid"
fi
