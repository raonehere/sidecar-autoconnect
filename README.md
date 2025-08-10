# Sidecar Auto Connect

Automatically connect your Mac to an iPad via Sidecar at login. perfect if your Mac’s built-in display is broken, or you run a headless setup.

## How it works
A small wrapper script waits for a reachable iPad, then calls the community CLI **SidecarLauncher** to start Sidecar.  
- Prefers USB, then falls back to Wi-Fi  
- Ignores device name changes by using the first reachable iPad from `devices`  
- Can auto-download the latest SidecarLauncher during install  

> **Note:** SidecarLauncher uses private Sidecar APIs. macOS updates can break compatibility. If it stops working, uninstall the LaunchAgent or switch to Duet Display / Luna Display.

---

## Requirements
- macOS and iPadOS versions that support Sidecar
- Same Apple ID on Mac and iPad
- Bluetooth and Wi-Fi on, or a USB-C cable
- This script auto-downloads **SidecarLauncher** from [Ocasio-J/SidecarLauncher](https://github.com/Ocasio-J/SidecarLauncher)

---

## Installation

### 1. Easy way (automatic)
Clone the repo and run the installer — it will:
- Download SidecarLauncher for you
- Install the wrapper script
- Set up and load the LaunchAgent

```bash
git clone https://github.com/raonehere/sidecar-autoconnect.git
cd sidecar-autoconnect
chmod +x install.sh
./install.sh
