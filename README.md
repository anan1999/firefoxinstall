# Board Browser Kit

This repository provides the board-side configuration and scripts for launching
Firefox directly on the Linux board GUI.

Firefox itself is downloaded from Mozilla's official download endpoint. This
keeps this repository small and avoids publishing large browser runtime files in
GitHub Releases.

## Recommended Install From PC Through ADB

Run these commands on the PC that is connected to the board:

```powershell
adb root
adb shell "cd /data/local/tmp && wget -O firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz && tar -xzf firefoxinstall-main.tar.gz && rm -rf board-browser-kit && mv firefoxinstall-main board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && ./scripts/download-firefox-esr && ./install.sh"
```

If the board does not have `wget`, use `curl`:

```powershell
adb root
adb shell "cd /data/local/tmp && curl -L -o firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz && tar -xzf firefoxinstall-main.tar.gz && rm -rf board-browser-kit && mv firefoxinstall-main board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && ./scripts/download-firefox-esr && ./install.sh"
```

The `adb shell` command is issued from the PC, but the download, extraction, and
installation run on the board.

## Install Directly On The Board

Use this only when operating from a terminal on the board itself:

```sh
cd /data/local/tmp
wget -O firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz
tar -xzf firefoxinstall-main.tar.gz
rm -rf board-browser-kit
mv firefoxinstall-main board-browser-kit
cd board-browser-kit
chmod +x install.sh scripts/*
./scripts/download-firefox-esr
./install.sh
```

## Firefox Download Source

The installer downloads Firefox ESR ARM64 from Mozilla:

```text
https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=linux64-aarch64&lang=en-US
```

On July 8, 2026, this redirected to Firefox ESR `140.12.0esr` for
`linux-aarch64`.

## Launch Browser From PC Through ADB

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox
```

Open a specific page:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.youtube.com
```

## Included Board Settings

- Browser launch wrapper for Wayland
- Local browser home page
- Network recovery helper for `eth0`
- Automatic time sync helper for HTTPS certificate validity
- systemd service files
- Memory snapshot and CSV monitoring tools
- Optional support for board-specific libraries, fonts, and Wayland guard files

See [docs/INSTALL_SOP.md](docs/INSTALL_SOP.md) for the full SOP.
