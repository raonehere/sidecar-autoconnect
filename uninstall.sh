#!/bin/bash
set -e

AGENT="${HOME}/Library/LaunchAgents/com.sidecar.autoconnect.plist"

# Unload LaunchAgent
launchctl bootout gui/$(id -u) "$AGENT" 2>/dev/null || true

# Remove files
rm -f "$AGENT"
rm -f "${HOME}/bin/sidecar_connect.sh"

echo "✅ Sidecar Auto Connect uninstalled."
echo "You can also remove ${HOME}/bin/SidecarLauncher if you no longer need it."
