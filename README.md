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
adb shell 'cd /data/local/tmp && rm -rf board-browser-kit && tar -xzf firefoxinstall-main.tar.gz && EXTRACT_DIR=$(tar -tzf firefoxinstall-main.tar.gz | sed -n 1p | cut -d/ -f1) && mv $EXTRACT_DIR board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && sh install.sh'
```

The GitHub package is downloaded on the PC and pushed to the board through ADB.
The Firefox download and installation run on the board. The installer uses the
board's Linux `/bin/sh`; do not use `/system/bin/sh` or assume an Android
directory layout.

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
