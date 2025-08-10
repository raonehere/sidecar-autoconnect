#!/bin/bash
set -e

USER_HOME="${HOME}"
USER_NAME="$(id -un)"

mkdir -p "${USER_HOME}/bin" "${USER_HOME}/Library/LaunchAgents"

# Ensure SidecarLauncher exists
if [ ! -x "${USER_HOME}/bin/SidecarLauncher" ]; then
  echo "❌ SidecarLauncher not found in ${USER_HOME}/bin/"
  echo "Place it there and run this script again."
  echo "If it's in Downloads, moving it now..."
  if [ -f "${USER_HOME}/Downloads/SidecarLauncher" ]; then
    mv "${USER_HOME}/Downloads/SidecarLauncher" "${USER_HOME}/bin/"
  fi
fi

chmod 755 "${USER_HOME}/bin/SidecarLauncher" 2>/dev/null || true
xattr -dr com.apple.quarantine "${USER_HOME}/bin/SidecarLauncher" 2>/dev/null || true

# Install connector script
install -m 755 "bin/sidecar_connect.sh" "${USER_HOME}/bin/sidecar_connect.sh"

# Install LaunchAgent (replace %USER% with username)
sed "s#%USER%#${USER_NAME}#g" "launch/com.sidecar.autoconnect.plist" > \
  "${USER_HOME}/Library/LaunchAgents/com.sidecar.autoconnect.plist"

# Validate plist
plutil -lint "${USER_HOME}/Library/LaunchAgents/com.sidecar.autoconnect.plist"

# Load and enable LaunchAgent
launchctl bootout gui/$(id -u) "${USER_HOME}/Library/LaunchAgents/com.sidecar.autoconnect.plist" 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "${USER_HOME}/Library/LaunchAgents/com.sidecar.autoconnect.plist"
launchctl enable gui/$(id -u)/com.sidecar.autoconnect
launchctl kickstart -k gui/$(id -u)/com.sidecar.autoconnect

echo "✅ Sidecar Auto Connect installed."
echo "Plug in and unlock your iPad."
echo "Logs: tail -f /tmp/sidecarlog.err"
