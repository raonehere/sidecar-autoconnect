#!/bin/bash
set -e

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"
BIN="${HOME}/bin/SidecarLauncher"

# Optional, set to 1 to force USB only
FORCE_WIRED="${FORCE_WIRED:-0}"

# Wait up to ~60s for any device to appear
for i in {1..12}; do
  DEV="$("$BIN" devices | head -n 1)"
  if [ -n "$DEV" ]; then
    if [ "$FORCE_WIRED" = "1" ]; then
      "$BIN" connect "$DEV" -wired && exit 0
    fi
    "$BIN" connect "$DEV" -wired && exit 0
    "$BIN" connect "$DEV" && exit 0
  fi
  sleep 5
done

echo "No Sidecar devices found after waiting." >&2
exit 3
