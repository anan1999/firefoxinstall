# Board Browser Kit Install SOP

This SOP installs the board-side browser settings from our GitHub repository
and downloads Firefox ESR ARM64 from Mozilla's official download endpoint.

Repository:

```text
https://github.com/anan1999/firefoxinstall
```

Firefox download source:

```text
https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=linux64-aarch64&lang=en-US
```

On July 8, 2026, the Mozilla link redirected to:

```text
https://download-installer.cdn.mozilla.net/pub/firefox/releases/140.12.0esr/linux-aarch64/en-US/firefox-140.12.0esr.tar.xz
```

Use the `download.mozilla.org` URL in SOPs because it tracks the latest Firefox
ESR ARM64 build.

## Online Install On The Board

Run these commands directly on the board:

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

If `wget` is not supported, use `curl`:

```sh
cd /data/local/tmp
curl -L -o firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz
tar -xzf firefoxinstall-main.tar.gz
rm -rf board-browser-kit
mv firefoxinstall-main board-browser-kit
cd board-browser-kit
chmod +x install.sh scripts/*
./scripts/download-firefox-esr
./install.sh
```

## ADB Install From PC

If the board cannot download from GitHub directly, download the repository ZIP
or tarball on the PC first, then push it to the board:

```powershell
curl.exe -L -o firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz
adb root
adb push firefoxinstall-main.tar.gz /data/local/tmp/
adb shell "cd /data/local/tmp && tar -xzf firefoxinstall-main.tar.gz && rm -rf board-browser-kit && mv firefoxinstall-main board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && ./scripts/download-firefox-esr && ./install.sh"
```

## Manual Firefox Download Only

If only Firefox needs to be refreshed:

```sh
cd /data/local/tmp/board-browser-kit
./scripts/download-firefox-esr
```

To pin a specific Firefox ESR package, override `FIREFOX_ESR_URL`:

```sh
cd /data/local/tmp/board-browser-kit
FIREFOX_ESR_URL="https://download-installer.cdn.mozilla.net/pub/firefox/releases/140.12.0esr/linux-aarch64/en-US/firefox-140.12.0esr.tar.xz" ./scripts/download-firefox-esr
```

## Launch Browser

Open the default board browser home page:

```sh
/data/local/tmp/board-browser-kit/board-open-firefox
```

Open a specific URL:

```sh
/data/local/tmp/board-browser-kit/board-open-firefox https://www.google.com
```

## Verify

Check network:

```sh
/data/local/tmp/board-browser-kit/board-network-up
ping -c 2 google.com
```

Check time sync:

```sh
/etc/board-time-sync
date
```

Check browser service:

```sh
systemctl status board-browser-ui.service
```

Check memory:

```sh
/data/local/tmp/board-browser-kit/board-memory-snapshot
```

Start CSV memory logging:

```sh
/data/local/tmp/board-browser-kit/board-memory-monitor 5 /tmp/board-memory-monitor.csv
```

## Notes

The tested board image needed extra runtime compatibility files, such as
board-specific libraries, CJK font configuration, and a Wayland resize guard.
The launch wrapper enables those files only when they exist under
`/data/local/tmp/board-browser-kit`.

## Uninstall

```sh
systemctl disable board-browser-ui.service 2>/dev/null || true
systemctl disable board-time-sync.service 2>/dev/null || true
rm -f /etc/systemd/system/board-browser-ui.service
rm -f /etc/systemd/system/board-time-sync.service
rm -f /etc/board-open-firefox
rm -f /etc/board-time-sync
rm -rf /data/local/tmp/board-browser-kit
systemctl daemon-reload 2>/dev/null || true
```
