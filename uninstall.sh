#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST="$HOME/Library/LaunchAgents/com.mikerosoft.mikey-mouse.plist"
TARGET_DIR="${1:-$HOME/.local/bin}"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: uninstall.sh [target_bin_dir] (default: ~/.local/bin)"
  exit 0
fi
if [[ "$#" -gt 1 || "${1:-}" == -* ]]; then
  echo "Usage: uninstall.sh [target_bin_dir]" >&2
  exit 2
fi

bash "$SCRIPT_DIR/kill.sh"
if [[ -f "$PLIST" ]]; then
  rm "$PLIST"
fi

# Leave launchers owned by another clone or another program alone.
LAUNCHER="$TARGET_DIR/mikey-mouse"
if [[ -L "$LAUNCHER" && "$(readlink "$LAUNCHER")" == "$SCRIPT_DIR/mikey-mouse" ]]; then
  rm "$LAUNCHER"
fi

echo "Stopped Mikey Mouse and removed it from login."
echo "The app remains at ${MIKEY_MOUSE_APP_DIR:-$HOME/Applications/Mikey Mouse.app} and can be removed manually."
