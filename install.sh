#!/usr/bin/env bash
# Symlink the launcher into PATH. App setup remains a separate, explicit step.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: install.sh [target_bin_dir] (default: ~/.local/bin)"
  exit 0
fi
if [[ "$#" -gt 1 || "${1:-}" == -* ]]; then
  echo "Usage: install.sh [target_bin_dir]" >&2
  exit 2
fi
TARGET_DIR="${1:-$HOME/.local/bin}"

mkdir -p "$TARGET_DIR"
chmod +x "$SCRIPT_DIR/mikey-mouse"
ln -sf "$SCRIPT_DIR/mikey-mouse" "$TARGET_DIR/mikey-mouse"
echo "Installed launcher: $TARGET_DIR/mikey-mouse -> $SCRIPT_DIR/mikey-mouse"
echo "Add $TARGET_DIR to PATH if needed. Re-run this script after moving the clone."
echo "Run bash \"$SCRIPT_DIR/setup_mac.sh\" to test, build and start Mikey Mouse.app."
