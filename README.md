# Board Browser Kit

Install the board-side scripts needed to launch Firefox directly on the Linux
board GUI. Firefox is downloaded from Mozilla during installation; this
repository only stores the board configuration and helper scripts.

## Quick Install

Run these commands on the PC connected to the board:

```powershell
curl.exe -L -o firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz
adb root
adb push firefoxinstall-main.tar.gz /data/local/tmp/
adb shell "cd /data/local/tmp && tar -xzf firefoxinstall-main.tar.gz && rm -rf board-browser-kit && mv firefoxinstall-main board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && ./scripts/download-firefox-esr && ./install.sh"
```

The GitHub package is downloaded on the PC and pushed to the board through ADB.
The Firefox download and installation run on the board.

## Launch

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox
```

Open a URL:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.youtube.com
```

## More Details

See [docs/INSTALL_SOP.md](docs/INSTALL_SOP.md) for:

- What the kit installs
- Firefox download source
- Verification commands
- Memory monitoring commands
- Known board-side `wget` GitHub TLS issue
- Uninstall command
