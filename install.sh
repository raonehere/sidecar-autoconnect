#!/bin/bash
set -e

# ---- settings
BIN_DIR="$HOME/bin"
SIDECAR_BIN="$BIN_DIR/SidecarLauncher"
TOGGLE_SCRIPT="$BIN_DIR/sidecar_toggle.sh"
HS_APP_SYS="/Applications/Hammerspoon.app"
HS_APP_USR="$HOME/Applications/Hammerspoon.app"
HS_CONF_DIR="$HOME/.hammerspoon"
HS_INIT="$HS_CONF_DIR/init.lua"

echo "📦 Installing Sidecar hotkey toggle (⌃⌥⌘M)…"
mkdir -p "$BIN_DIR" "$HOME/Applications" "$HS_CONF_DIR"

# 1) Get SidecarLauncher
if [ ! -x "$SIDECAR_BIN" ]; then
  echo "⬇️  Downloading SidecarLauncher…"
  API="https://api.github.com/repos/Ocasio-J/SidecarLauncher/releases/latest"
  DL_URL=$(curl -fsSL "$API" \
    | grep -Eo '"browser_download_url":\s*"[^"]+"' \
    | sed 's/.*"browser_download_url":\s*"\(.*\)".*/\1/' \
    | grep -E '/SidecarLauncher$' | head -n 1)
  if [ -z "$DL_URL" ]; then
    echo "❌ Could not find SidecarLauncher download URL. Try later."
    exit 1
  fi
  curl -fL "$DL_URL" -o "$SIDECAR_BIN"
fi
chmod 755 "$SIDECAR_BIN"
xattr -dr com.apple.quarantine "$SIDECAR_BIN" 2>/dev/null || true

# 2) Install the toggle script
cat > ~/bin/sidecar_toggle.sh <<'SH'
#!/bin/bash
set -e

LOCK="/tmp/sidecar_hotkey.lock"
# simple debounce: if another run is active, bail
if [ -e "$LOCK" ] && kill -0 "$(cat "$LOCK")" 2>/dev/null; then
  exit 0
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
BIN="$HOME/bin/SidecarLauncher"

# If Sidecar is running, disconnect ONCE
if pgrep -x "SidecarDisplayAgent" >/dev/null 2>&1; then
  DEV="$("$BIN" devices | head -n 1)"
  [ -n "$DEV" ] && exec "$BIN" disconnect "$DEV"
  exit 0
fi

# Not running: connect with ONE wired attempt, then ONE wireless attempt
DEV="$("$BIN" devices | head -n 1)"
[ -z "$DEV" ] && exit 1
"$BIN" connect "$DEV" -wired || "$BIN" connect "$DEV"
SH
chmod 755 ~/bin/sidecar_toggle.sh


# 3) Install Hammerspoon if missing (to provide a reliable global hotkey)
if [ ! -d "$HS_APP_SYS" ] && [ ! -d "$HS_APP_USR" ]; then
  echo "⬇️  Downloading Hammerspoon…"
  HS_API="https://api.github.com/repos/Hammerspoon/hammerspoon/releases/latest"
  HS_ZIP=$(curl -fsSL "$HS_API" \
    | grep -Eo '"browser_download_url":\s*"[^"]+"' \
    | sed 's/.*"browser_download_url":\s*"\(.*\)".*/\1/' \
    | grep -E '\.zip$' | head -n 1)
  if [ -z "$HS_ZIP" ]; then
    echo "❌ Could not find Hammerspoon download URL."
    echo "Download manually from https://github.com/Hammerspoon/hammerspoon/releases and drag to ~/Applications"
    exit 1
  fi
  TMP_ZIP="$(mktemp /tmp/hs.XXXXXX.zip)"
  curl -fL "$HS_ZIP" -o "$TMP_ZIP"
  ditto -x -k "$TMP_ZIP" "$HOME/Applications"
  rm -f "$TMP_ZIP"
fi

# 4) Configure hotkey (⌃⌥⌘M)
if [ -f "$HS_INIT" ]; then
  cp "$HS_INIT" "$HS_INIT.bak.$(date +%s)" 2>/dev/null || true
fi
cat > "$HS_INIT" <<LUA
-- Sidecar hotkey toggle
hs.hotkey.bind({"ctrl","alt","cmd"}, "M", function()
  hs.task.new("/usr/bin/env", nil, {"bash","-lc","$TOGGLE_SCRIPT"}):start()
end)
hs.alert.show("Sidecar hotkey ready: Ctrl+Alt+Cmd+M")
LUA

# 5) Launch Hammerspoon (user grants Accessibility once)
open -a "$HS_APP_SYS" 2>/dev/null || open -a "$HS_APP_USR"

echo
echo "✅ Done."
echo "➡️  If prompted, open System Settings → Privacy & Security → Accessibility and enable Hammerspoon."
echo "   After that, press Ctrl+Alt+Cmd+M to connect/disconnect Sidecar."
