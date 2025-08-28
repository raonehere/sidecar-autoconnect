````md
# Sidecar Auto Connect

Press one hotkey to connect or disconnect Sidecar.  
No auto run. Beginner friendly. Works over USB or Wi Fi.

## What it does
- Installs a tiny toggle script that connects to the first reachable iPad
- Sets up a global hotkey with Hammerspoon, default is Ctrl Option Command M
- Tries wired first, then falls back to wireless
- No LaunchAgents, nothing runs at login

## Quick start
Paste this in Terminal
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/raonehere/sidecar-autoconnect/main/install.sh)"
````

During install, macOS will ask you to allow Accessibility for Hammerspoon. Approve it.
Then press **Ctrl + Option + Command + M** to connect.
Press the same keys again to disconnect.
Press again to reconnect.

## Requirements

* A Mac and an iPad that support Sidecar
* Same Apple ID on both devices
* Bluetooth and Wi Fi on, or a USB C cable
* Internet access during install, the script downloads SidecarLauncher and Hammerspoon for you

## How it works

* The installer puts **SidecarLauncher** at `~/bin/SidecarLauncher`
* It creates `~/bin/sidecar_toggle.sh`

  * If a Sidecar session is running, it disconnects
  * If not running, it waits for a device, prefers wired, then connects
  * It retries a few times and restarts Sidecar agents between attempts
* It writes `~/.hammerspoon/init.lua` with a single hotkey that runs the toggle script

## Uninstall

You can remove everything with one command

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/raonehere/sidecar-autoconnect/main/uninstall.sh)"
```

This stops old auto connect agents if any, removes the toggle script, and backs up your Hammerspoon config.
You can also quit and delete Hammerspoon from Applications if you prefer.

## Troubleshooting

**The installer finished but the hotkey does nothing**

1. Open the Hammerspoon app once. If asked, allow Accessibility in System Settings, Privacy and Security, Accessibility.
2. Click the Hammerspoon menu icon and choose Reload Config.

**I get Unable to connect, device timed out**

1. Unlock the iPad and keep the screen on
2. Use a direct USB C cable and try again
3. Turn Bluetooth off and on on both devices
4. Make sure both devices use the same Apple ID
5. Run this once to clear stale state, then press the hotkey again

   ```bash
   pkill -x SidecarDisplayAgent 2>/dev/null
   pkill -x SidecarRelay 2>/dev/null
   ```

**My iPad name has curly quotes**
The tool uses the first device it finds, so the name does not matter.
If you still want to simplify, rename the iPad to a plain ASCII name like Rahul iPad.

**I want a different hotkey**
Open `~/.hammerspoon/init.lua` and change the key.
Example for Ctrl Option Command K

```lua
hs.hotkey.bind({"ctrl","alt","cmd"}, "K", function()
  hs.task.new("/usr/bin/env", nil, {"bash","-lc","$HOME/bin/sidecar_toggle.sh"}):start()
end)
```

Click the Hammerspoon menu icon, Reload Config.

## Security notes

* The installer downloads SidecarLauncher from the official GitHub release API
* Scripts are plain text, you can read them before running
* No background daemons are installed, no login items are added

## Credits

* Sidecar control is powered by the community CLI **SidecarLauncher** by Ocasio J
* Packaging and hotkey toggle by contributors to this repo

## License

MIT

```
::contentReference[oaicite:0]{index=0}
```
