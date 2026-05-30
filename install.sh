#!/usr/bin/env bash
set -euo pipefail

XRDEPLOY_REPO="${XRDEPLOY_REPO:-https://raw.githubusercontent.com/USERNAME/xrdeploy/main}"
XRDEPLOY_BIN="/usr/local/bin/xrdeploy"
XRDEPLOY_LIB="/usr/local/lib/xrdeploy"

echo "[xrdeploy] installing dependencies"
apt update
apt install -y curl wget unzip ca-certificates openssl python3

if ! command -v xray >/dev/null 2>&1; then
  echo "[xrdeploy] installing Xray core"
  bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install
fi

echo "[xrdeploy] installing xrdeploy CLI"
install -d -m 755 "$XRDEPLOY_LIB"
curl -fsSL "$XRDEPLOY_REPO/xrdeploy" -o "$XRDEPLOY_BIN"
curl -fsSL "$XRDEPLOY_REPO/tools/reality_check.sh" -o "$XRDEPLOY_LIB/reality_check.sh"
curl -fsSL "$XRDEPLOY_REPO/uninstall.sh" -o "$XRDEPLOY_LIB/uninstall.sh"
chmod +x "$XRDEPLOY_BIN" "$XRDEPLOY_LIB/reality_check.sh" "$XRDEPLOY_LIB/uninstall.sh"

echo "[xrdeploy] done"
echo "Run: sudo xrdeploy"
