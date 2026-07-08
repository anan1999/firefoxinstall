# Board Browser Kit Install SOP

This SOP installs board-side browser configuration from our GitHub repository
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

Use the `download.mozilla.org` URL in the SOP because it tracks the latest
Firefox ESR ARM64 build.

## Recommended Install From PC Through ADB

Run these commands on the PC that is connected to the board:

```powershell
curl.exe -L -o firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz
adb root
adb push firefoxinstall-main.tar.gz /data/local/tmp/
adb shell "cd /data/local/tmp && tar -xzf firefoxinstall-main.tar.gz && rm -rf board-browser-kit && mv firefoxinstall-main board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && ./scripts/download-firefox-esr && ./install.sh"
```

The GitHub package is downloaded on the PC, then pushed to the board through
ADB. This avoids relying on the board's `wget` TLS support.

The `adb shell` command is typed on the PC. The command body runs on the board,
so Mozilla must be reachable from the board network.

## Optional: Download GitHub Package Directly On The Board

Use this only when the board's `wget` can download from GitHub successfully:

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

On the tested board, direct GitHub download from board-side `wget` failed with:

```text
wget: TLS error from peer (alert code 80): 80
wget: error getting response: Connection reset by peer
```

For that board, use the recommended PC download plus `adb push` flow.

## Alternative: Install Directly On The Board After Manual Transfer

Use this when the package has already been copied to
`/data/local/tmp/firefoxinstall-main.tar.gz`:

```sh
cd /data/local/tmp
tar -xzf firefoxinstall-main.tar.gz
rm -rf board-browser-kit
mv firefoxinstall-main board-browser-kit
cd board-browser-kit
chmod +x install.sh scripts/*
./scripts/download-firefox-esr
./install.sh
```

## Manual Firefox Download Only

If only Firefox needs to be refreshed:

```powershell
adb shell "cd /data/local/tmp/board-browser-kit && ./scripts/download-firefox-esr"
```

To pin a specific Firefox ESR package:

```powershell
adb shell "cd /data/local/tmp/board-browser-kit && FIREFOX_ESR_URL='https://download-installer.cdn.mozilla.net/pub/firefox/releases/140.12.0esr/linux-aarch64/en-US/firefox-140.12.0esr.tar.xz' ./scripts/download-firefox-esr"
```

## Launch Browser From PC Through ADB

Open the default board browser home page:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox
```

Open a specific URL:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.google.com
```

## Verify

Check network:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-network-up
adb shell ping -c 2 google.com
```

Check time sync:

```powershell
adb shell /etc/board-time-sync
adb shell date
```

Check browser service:

```powershell
adb shell systemctl status board-browser-ui.service
```

Check memory:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-memory-snapshot
```

Start CSV memory logging:

```powershell
adb shell "/data/local/tmp/board-browser-kit/board-memory-monitor 5 /tmp/board-memory-monitor.csv >/tmp/board-memory-monitor.log 2>&1 &"
```

Pull the memory log back to the PC:

```powershell
adb pull /tmp/board-memory-monitor.csv .
```

## Notes

The tested board image needed extra runtime compatibility files, such as
board-specific libraries, CJK font configuration, and a Wayland resize guard.
The launch wrapper enables those files only when they exist under
`/data/local/tmp/board-browser-kit`.

## Uninstall From PC Through ADB

```powershell
adb shell "systemctl disable board-browser-ui.service 2>/dev/null || true; systemctl disable board-time-sync.service 2>/dev/null || true; rm -f /etc/systemd/system/board-browser-ui.service; rm -f /etc/systemd/system/board-time-sync.service; rm -f /etc/board-open-firefox; rm -f /etc/board-time-sync; rm -rf /data/local/tmp/board-browser-kit; systemctl daemon-reload 2>/dev/null || true"
```
