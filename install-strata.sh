#!/usr/bin/env bash
set -euo pipefail

# Beim Aufruf überschreibbar, z.B.:
# DATA_DRIVE=/mnt/data bash install-strata.sh
DATA_DRIVE="${DATA_DRIVE:-/data}"

STRATA_APP="$DATA_DRIVE/ai/Strata-DGX-Spark"
STRATA_MODELS="$DATA_DRIVE/ai/Strata-data"

# Grundlegende Prüfungen
case "$(uname -m)" in
  aarch64|arm64) ;;
  *) echo "Dieses Skript ist für den ARM64-GX10/DGX Spark."; exit 1 ;;
esac

if [[ ! -d "$DATA_DRIVE" ]]; then
  echo "Data Drive nicht gefunden: $DATA_DRIVE"
  exit 1
fi

echo "Bitte prüfen: Hier liegt das ausgewählte Data Drive:"
findmnt -T "$DATA_DRIVE"
df -h "$DATA_DRIVE"

nvidia-smi

# Der GB10-Fork setzt CUDA Toolkit 13.0 voraus.
CUDA_ROOT="${CUDA_ROOT:-/usr/local/cuda}"
if [[ ! -x "$CUDA_ROOT/bin/nvcc" ]]; then
  echo "CUDA Toolkit fehlt unter $CUDA_ROOT."
  echo "CUDA Toolkit 13.0 installieren oder CUDA_ROOT passend setzen."
  exit 1
fi

"$CUDA_ROOT/bin/nvcc" --version

export PATH="$CUDA_ROOT/bin:$PATH"
export CUDACXX="$CUDA_ROOT/bin/nvcc"

sudo apt-get update
sudo apt-get install -y \
  git build-essential python3 python3-venv python3-pip curl

# Diese Verzeichnisse müssen deinem Benutzer gehören.
mkdir -p "$STRATA_MODELS"

if [[ ! -d "$STRATA_APP" ]]; then
  git clone https://github.com/shi3z/Strata-DGX-Spark.git "$STRATA_APP"
fi

cd "$STRATA_APP"

./setup.sh \
  --yes \
  --family coder \
  --model IQ1_M \
  --context 32768 \
  --vision no \
  --experimental-speed-projection off \
  --data-dir "$STRATA_MODELS" \
  --host 127.0.0.1 \
  --port 8080 \
  --no-browser \
  --no-start

echo
echo "Installation fertig. Server starten mit:"
echo "cd \"$STRATA_APP\""
echo "./run-coder-iq1_m.sh"