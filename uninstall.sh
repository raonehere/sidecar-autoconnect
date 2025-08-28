#!/bin/bash
set -e
echo "🧹 Removing Sidecar hotkey toggle…"

launchctl bootout gui/$(id -u)/com.rahul.sidecar-autoconnect 2>/dev/null || true
launchctl bootout gui/$(id -u)/com.sidecar.autoconnect 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.rahul.sidecar-autoconnect.plist" \
      "$HOME/Library/LaunchAgents/com.sidecar.autoconnect.plist"

rm -f "$HOME/bin/sidecar_connect.sh" \
      "$HOME/bin/sidecar_once.sh" \
      "$HOME/bin/sidecar_toggle.sh"

# keep SidecarLauncher by default (users may want it)
# rm -f "$HOME/bin/SidecarLauncher"

if [ -f "$HOME/.hammerspoon/init.lua" ]; then
  mv "$HOME/.hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua.bak.$(date +%s)"
fi

echo "✅ Uninstalled. You can quit Hammerspoon and delete it from Applications if you like."
