# Sidecar Auto Connect

Automatically connect your Mac to an iPad via Sidecar at login. Great when your Mac’s built-in display is dead, or for headless desks.

## How it works
A tiny wrapper waits for a reachable iPad, then calls the community CLI **SidecarLauncher** to start Sidecar. It prefers USB, then falls back to Wi-Fi. It ignores device name changes by using the first reachable device from `devices`.

> SidecarLauncher uses private Sidecar APIs. It can break after macOS updates. If it stops working, remove the LaunchAgent or switch to Duet Display or Luna Display.

## Requirements
- macOS and iPadOS versions that support Sidecar
- Same Apple ID on Mac and iPad
- Bluetooth and Wi-Fi on, or a USB-C cable
- **SidecarLauncher** placed at `~/bin/SidecarLauncher`
  - Project: `Ocasio-J/SidecarLauncher` on GitHub

## Install
1. Put the `SidecarLauncher` binary at `~/bin/SidecarLauncher` and make it executable.
2. Copy these two files into your home directory:
   - `bin/sidecar_connect.sh`
   - `launch/com.sidecar.autoconnect.plist`
3. Run:
   ```bash
   chmod 755 ~/bin/sidecar_connect.sh
   plutil -lint ~/launch/com.sidecar.autoconnect.plist 2>/dev/null || true
   mkdir -p ~/Library/LaunchAgents
   cp ~/launch/com.sidecar.autoconnect.plist ~/Library/LaunchAgents/

   launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.sidecar.autoconnect.plist 2>/dev/null || true
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.sidecar.autoconnect.plist
   launchctl enable gui/$(id -u)/com.sidecar.autoconnect
   launchctl kickstart -k gui/$(id -u)/com.sidecar.autoconnect
