#!/usr/bin/env bash
set -euo pipefail
APP=/data/ai/Strata-DGX-Spark
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG="$ROOT/strata-coder-iq1_m-64k.json"
if curl --fail --silent --max-time 2 http://127.0.0.1:8080/health >/dev/null; then
  echo 'Stop the existing Strata server (Ctrl+C in its terminal) before starting the 64K model.' >&2
  exit 1
fi
python3 - "$APP/strata-coder-iq1_m.json" "$CONFIG" <<'PY'
import json
import sys
from pathlib import Path

config = json.loads(Path(sys.argv[1]).read_text())
args = config['args']
args[args.index('--max-context') + 1] = '65536'
config['model_name'] = 'qwen3.8-flash-next-coder-iq1_m-64k'
config['log'] = str(Path(sys.argv[2]).with_suffix('.log'))
Path(sys.argv[2]).write_text(json.dumps(config, indent=2) + '\n')
PY
cd "$APP"
exec "$APP/.venv/bin/python" "$APP/serve/server.py" --engine strata --config "$CONFIG" --port 8080
