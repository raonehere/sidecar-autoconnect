#!/bin/bash
set -e

REPO_USER="Ocasio-J"
REPO_NAME="SidecarLauncher"

USER_HOME="${HOME}"
USER_NAME="$(id -un)"
BIN_DIR="${USER_HOME}/bin"
AGENTS_DIR="${USER_HOME}/Library/LaunchAgents"
AGENT_DEST="${AGENTS_DIR}/com.sidecar.autoconnect.plist"
CONNECT_SCRIPT_SRC="bin/sidecar_connect.sh"
PLIST_TEMPLATE="launch/com.sidecar.autoconnect.plist"
SIDECAR_BIN="${BIN_DIR}/SidecarLauncher"

echo "Setting up folders..."
mkdir -p "${BIN_DIR}" "${AGENTS_DIR}"

# 1) Get SidecarLauncher automatically if missing
if [ ! -x "${SIDECAR_BIN}" ]; then
  echo "Downloading SidecarLauncher..."
  API_URL="https://api.github.com/repos/${REPO_USER}/${REPO_NAME}/releases/latest"
  DL_URL=$(
    curl -fsSL "$API_URL" \
    | grep -Eo '"browser_download_url":\s*"[^"]+"' \
    | sed 's/"browser_download_url":\s*"\(.*\)"/\1/' \
    | grep -E '/releases/download/.*/SidecarLauncher$' \
    | head -n 1
  )

  if [ -z "$DL_URL" ]; then
    echo "Could not find download URL from GitHub API."
    echo "Please download SidecarLauncher manually and place it at ${SIDECAR_BIN}"
    exit 1
  fi

  curl -fL "$DL_URL" -o "${SIDECAR_BIN}.tmp"
  mv "${SIDECAR_BIN}.tmp" "${SIDECAR_BIN}"
fi

chmod 755 "${SIDECAR_BIN}" 2>/dev/null || true
xattr -dr com.apple.quarantine "${SIDECAR_BIN}" 2>/dev/null || true

# 2) Install connector script
echo "Installing connector script..."
install -m 755 "${CONNECT_SCRIPT_SRC}" "${BIN_DIR}/sidecar_connect.sh"

# 3) Install LaunchAgent from template
echo "Installing LaunchAgent..."
sed "s#%USER%#${USER_NAME}#g" "${PLIST_TEMPLATE}" > "${AGENT_DEST}"
plutil -lint "${AGENT_DEST}"

# 4) Load agent
echo "Starting LaunchAgent..."
launchctl bootout gui/$(id -u) "${AGENT_DEST}" 2>/dev/null || true
launchctl bootstrap gui/$(id -u) "${AGENT_DEST}"
launchctl enable gui/$(id -u)/com.sidecar.autoconnect
launchctl kickstart -k gui/$(id -u)/com.sidecar.autoconnect

echo
echo "All set. Plug in and unlock your iPad."
echo "To check status: launchctl print gui/\$(id -u)/com.sidecar.autoconnect | head -n 40"
echo "Logs: tail -f /tmp/sidecarlog.err  (only if you added logging keys in the plist)"
