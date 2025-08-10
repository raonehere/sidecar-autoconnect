#!/bin/bash
set -e

REPO_USER="raonehere"
REPO_NAME="sidecar-autoconnect"
BIN_DIR="${HOME}/bin"
AGENTS_DIR="${HOME}/Library/LaunchAgents"
CONNECT_SCRIPT="${BIN_DIR}/sidecar_connect.sh"
PLIST_FILE="${AGENTS_DIR}/com.sidecar.autoconnect.plist"
SIDECAR_BIN="${BIN_DIR}/SidecarLauncher"

echo "📦 Setting up Sidecar Auto Connect..."
mkdir -p "$BIN_DIR" "$AGENTS_DIR"

# Download SidecarLauncher
if [ ! -x "$SIDECAR_BIN" ]; then
  echo "⬇️  Downloading SidecarLauncher..."
  API_URL="https://api.github.com/repos/Ocasio-J/SidecarLauncher/releases/latest"
  DL_URL=$(curl -fsSL "$API_URL" | grep -Eo '"browser_download_url":\s*"[^"]+"' \
    | sed 's/"browser_download_url":\s*"\(.*\)"/\1/' \
    | grep -E '/SidecarLauncher$' | head -n 1)
  curl -fL "$DL_URL" -o "$SIDECAR_BIN"
fi
chmod 755 "$SIDECAR_BIN" && xattr -dr com.apple.quarantine "$SIDECAR_BIN" 2>/dev/null || true

# Download wrapper script
echo "⬇️  Downloading connector script..."
curl -fsSL "https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/bin/sidecar_connect.sh" -o "$CONNECT_SCRIPT"
chmod 755 "$CONNECT_SCRIPT"

# Download and patch plist
echo "⬇️  Downloading LaunchAgent..."
curl -fsSL "https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/launch/com.sidecar.autoconnect.plist" \
  | sed "s#%USER%#$(id -un)#g" > "$PLIST_FILE"
plutil -lint "$PLIST_FILE"

# Enable LaunchAgent
echo "🚀 Starting LaunchAgent..."
launchctl bootout gui/$(id -u) "$PLIST_FILE" 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "$PLIST_FILE"
launchctl enable gui/$(id -u)/com.sidecar.autoconnect
launchctl kickstart -k gui/$(id -u)/com.sidecar.autoconnect

echo "✅ Done! Plug in and unlock your iPad."
