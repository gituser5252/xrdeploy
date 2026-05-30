#!/usr/bin/env bash
set -euo pipefail

XRDEPLOY_BIN="/usr/local/bin/xrdeploy"
XRDEPLOY_LIB="/usr/local/lib/xrdeploy"
XRDEPLOY_STATE="/etc/xrdeploy"
XRAY_CONFIG_DIR="/usr/local/etc/xray"
XRAY_SHARE_DIR="/usr/local/share/xray"
XRAY_BIN="/usr/local/bin/xray"
XRAY_SERVICE="/etc/systemd/system/xray.service"

ask_yes_no() {
  local prompt="$1"
  local default="${2:-N}"
  local ans
  if [[ "$default" =~ ^[Yy]$ ]]; then
    read -r -p "$prompt [Y/n]: " ans || true
    [[ -z "${ans:-}" || "$ans" =~ ^[Yy]$ ]]
  else
    read -r -p "$prompt [y/N]: " ans || true
    [[ "${ans:-}" =~ ^[Yy]$ ]]
  fi
}

backup_path="/root/xrdeploy-backup-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "[xrdeploy] uninstall"

if ask_yes_no "Create backup before uninstall?" "Y"; then
  tmpdir="$(mktemp -d)"
  mkdir -p "$tmpdir/backup"
  [[ -d "$XRDEPLOY_STATE" ]] && cp -a "$XRDEPLOY_STATE" "$tmpdir/backup/xrdeploy-state" || true
  [[ -d "$XRAY_CONFIG_DIR" ]] && cp -a "$XRAY_CONFIG_DIR" "$tmpdir/backup/xray-config" || true
  tar -czf "$backup_path" -C "$tmpdir/backup" .
  rm -rf "$tmpdir"
  echo "[xrdeploy] backup saved: $backup_path"
fi

echo "[xrdeploy] removing xrdeploy files"
rm -f "$XRDEPLOY_BIN"
rm -rf "$XRDEPLOY_LIB"

if ask_yes_no "Remove /etc/xrdeploy state directory?" "N"; then
  rm -rf "$XRDEPLOY_STATE"
fi

if ask_yes_no "Remove Xray core and Xray config too?" "N"; then
  echo "[xrdeploy] stopping Xray"
  systemctl stop xray 2>/dev/null || true
  systemctl disable xray 2>/dev/null || true

  rm -f "$XRAY_BIN"
  rm -rf "$XRAY_SHARE_DIR"
  rm -rf "$XRAY_CONFIG_DIR"
  rm -f "$XRAY_SERVICE"
  rm -f /etc/systemd/system/xray@.service
  systemctl daemon-reload 2>/dev/null || true
fi

if command -v ufw >/dev/null 2>&1; then
  if ask_yes_no "Show UFW status now?" "N"; then
    ufw status numbered || true
    echo "Remove rules manually with: sudo ufw delete <number>"
  fi
fi

echo "[xrdeploy] done"
