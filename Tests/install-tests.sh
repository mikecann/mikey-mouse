#!/usr/bin/env bash
# Exercise installer ownership in a temporary home, without touching launchd.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
trap 'rm -rf "$TEST_DIR"' EXIT
export HOME="$TEST_DIR/home"
mkdir -p "$HOME" "$TEST_DIR/mocks"
for command in launchctl pkill; do
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TEST_DIR/mocks/$command"
  chmod +x "$TEST_DIR/mocks/$command"
done
export PATH="$TEST_DIR/mocks:$PATH"
cd "$TEST_DIR"

# The default location and a custom path containing spaces both work from any cwd.
bash "$REPO_DIR/install.sh"
[[ "$(readlink "$HOME/.local/bin/mikey-mouse")" == "$REPO_DIR/mikey-mouse" ]]
CUSTOM_BIN="$TEST_DIR/custom bin"
bash "$REPO_DIR/install.sh" "$CUSTOM_BIN"
bash "$REPO_DIR/install.sh" "$CUSTOM_BIN"
[[ "$(readlink "$CUSTOM_BIN/mikey-mouse")" == "$REPO_DIR/mikey-mouse" ]]

# The installed launcher is a symlink, so it must find the scripts next to its
# real path rather than in the bin directory. `stop` only runs kill.sh, which
# uses the mocked launchctl and pkill. Also follow a relative link to that link.
"$HOME/.local/bin/mikey-mouse" stop
"$CUSTOM_BIN/mikey-mouse" stop
mkdir -p "$TEST_DIR/chained"
ln -s "../custom bin/mikey-mouse" "$TEST_DIR/chained/mikey-mouse"
"$TEST_DIR/chained/mikey-mouse" stop
rm "$TEST_DIR/chained/mikey-mouse"

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Applications/Mikey Mouse.app"
touch "$HOME/Library/LaunchAgents/com.mikerosoft.mikey-mouse.plist"
touch "$HOME/Library/LaunchAgents/unrelated.plist" "$CUSTOM_BIN/other-tool"
bash "$REPO_DIR/uninstall.sh" "$CUSTOM_BIN"
[[ ! -L "$CUSTOM_BIN/mikey-mouse" ]]
[[ ! -e "$HOME/Library/LaunchAgents/com.mikerosoft.mikey-mouse.plist" ]]
[[ -f "$HOME/Library/LaunchAgents/unrelated.plist" ]]
[[ -f "$CUSTOM_BIN/other-tool" ]]
[[ -d "$HOME/Applications/Mikey Mouse.app" ]]

# Another checkout's launcher must survive this checkout's uninstaller.
ln -s "$TEST_DIR/another-checkout/mikey-mouse" "$CUSTOM_BIN/mikey-mouse"
bash "$REPO_DIR/uninstall.sh" "$CUSTOM_BIN"
[[ "$(readlink "$CUSTOM_BIN/mikey-mouse")" == "$TEST_DIR/another-checkout/mikey-mouse" ]]
bash "$REPO_DIR/uninstall.sh"
[[ ! -L "$HOME/.local/bin/mikey-mouse" ]]
bash "$REPO_DIR/uninstall.sh"

echo "Installer checks passed."
