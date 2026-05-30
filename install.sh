#!/usr/bin/env bash
set -euo pipefail

XRDEPLOY_REPO="${XRDEPLOY_REPO:-https://raw.githubusercontent.com/USERNAME/xrdeploy/main}"
XRDEPLOY_BIN="/usr/local/bin/xrdeploy"

echo "[xrdeploy] installing dependencies"
apt update
apt install -y curl wget unzip ca-certificates openssl python3

if ! command -v xray >/dev/null 2>&1; then
  echo "[xrdeploy] installing Xray core"
  bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
fi

echo "[xrdeploy] installing xrdeploy CLI"
curl -fsSL "$XRDEPLOY_REPO/xrdeploy" -o "$XRDEPLOY_BIN"
chmod +x "$XRDEPLOY_BIN"

echo "[xrdeploy] done"
echo "Run: sudo xrdeploy"
