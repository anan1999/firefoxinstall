# Board Browser Kit Install SOP

This SOP installs Firefox support on the Linux board GUI. The GitHub repository
contains only configuration and scripts. Firefox ESR ARM64 is downloaded from
Mozilla during installation.

## What Board Browser Kit Configures

`board-browser-kit` is not only a Firefox downloader. It also installs the
board-side settings needed to run Firefox directly on the Linux GUI.

| Item | Path | Purpose |
| --- | --- | --- |
| Firefox launcher | `/data/local/tmp/board-browser-kit/board-open-firefox` | Starts Firefox on the board GUI through Wayland. It sets `MOZ_ENABLE_WAYLAND`, `WAYLAND_DISPLAY`, `XDG_RUNTIME_DIR`, Firefox profile/cache paths, optional fontconfig, optional runtime libraries, and optional Wayland guard preload. |
| System launcher copy | `/etc/board-open-firefox` | Provides a stable system-level command path for services or manual launch. |
| Browser home page | `/data/local/tmp/board-browser-kit/board-firefox-home.html` | Local start page with URL input and quick links. This gives the user a simple UI after Firefox opens. |
| Network helper | `/data/local/tmp/board-browser-kit/board-network-up` | Checks board network before launching Firefox. It brings up `eth0`, runs DHCP through `udhcpc`, and repairs the default route when needed. |
| Time sync helper | `/etc/board-time-sync` | Syncs board time through NTP. This avoids HTTPS certificate failures when board time is wrong. |
| Browser service | `/etc/systemd/system/board-browser-ui.service` | Optional systemd service for launching the browser after the GUI/Wayland socket is ready. |
| Time sync service | `/etc/systemd/system/board-time-sync.service` | Runs time synchronization during boot. |
| Post-boot hook | `/etc/init.post_boot.sh` | Adds a delayed time-sync call after boot when this file exists on the board image. |
| Memory snapshot | `/data/local/tmp/board-browser-kit/board-memory-snapshot` | Prints one-time RAM, swap, memory pressure, browser service state, Firefox RSS, and top memory processes. |
| Memory monitor | `/data/local/tmp/board-browser-kit/board-memory-monitor` | Writes a CSV memory log at a fixed interval for long-running observation. |

Optional compatibility files are enabled only when they exist:

| Optional item | Path | Purpose |
| --- | --- | --- |
| Runtime libraries | `/data/local/tmp/board-browser-kit/firefox-libs/` | Adds extra `.so` search paths through `LD_LIBRARY_PATH` when the board image does not provide all Firefox dependencies. |
| Font files | `/data/local/tmp/board-browser-kit/fonts/` | Stores optional CJK fonts such as Noto Sans TC. |
| Fontconfig | `/data/local/tmp/board-browser-kit/fontconfig/fonts.conf` | Points Firefox/fontconfig to the bundled fonts so Chinese text can render correctly. |
| Wayland guard | `/data/local/tmp/board-browser-kit/libwayland_resize_guard.so` | Optional `LD_PRELOAD` workaround for board images that hit Wayland resize protocol issues. |

## Download Sources

Board Browser Kit repository:

```text
https://github.com/anan1999/firefoxinstall
```

Firefox ESR ARM64 official Mozilla endpoint:

```text
https://download.mozilla.org/?product=firefox-esr-latest-ssl&os=linux64-aarch64&lang=en-US
```

On July 8, 2026, this redirected to Firefox ESR `140.12.0esr` for
`linux-aarch64`.

## Recommended Install From PC Through ADB

Run these commands on the PC connected to the board:

```powershell
curl.exe -L -o firefoxinstall-main.tar.gz https://github.com/anan1999/firefoxinstall/archive/refs/heads/main.tar.gz
adb root
adb push firefoxinstall-main.tar.gz /data/local/tmp/
adb shell "cd /data/local/tmp && tar -xzf firefoxinstall-main.tar.gz && rm -rf board-browser-kit && mv firefoxinstall-main board-browser-kit && cd board-browser-kit && chmod +x install.sh scripts/* && ./scripts/download-firefox-esr && ./install.sh"
```

Reason for this flow:

- The PC downloads the GitHub package.
- ADB transfers the package to the board.
- The board extracts the package, downloads Firefox from Mozilla, and installs the board settings.
- This avoids relying on the board's `wget` TLS compatibility with GitHub.

## Optional Direct Board Download

Use this only if the board can download GitHub archives with `wget`:

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

On the tested board, direct GitHub download from board-side `wget` failed:

```text
wget: TLS error from peer (alert code 80): 80
wget: error getting response: Connection reset by peer
```

For that board, use the PC download plus `adb push` flow.

## Launch Browser

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox
```

Open a specific URL:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.google.com
```

## Verify

Network:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-network-up
adb shell ping -c 2 google.com
```

Time sync:

```powershell
adb shell /etc/board-time-sync
adb shell date
```

Service state:

```powershell
adb shell systemctl status board-browser-ui.service
adb shell systemctl status board-time-sync.service
```

Memory snapshot:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-memory-snapshot
```

Start CSV memory logging:

```powershell
adb shell "/data/local/tmp/board-browser-kit/board-memory-monitor 5 /tmp/board-memory-monitor.csv >/tmp/board-memory-monitor.log 2>&1 &"
adb pull /tmp/board-memory-monitor.csv .
```

## Smoke Test Results

Validated on July 8, 2026:

- `adb devices` detected the board.
- Board time was correct.
- Board had `wget`, `tar`, and `xz`.
- Board could ping `github.com`.
- Board could ping `download.mozilla.org`.
- PC could download the GitHub tarball with `curl.exe`.
- `adb push` transferred the tarball to the board.
- Board could extract the tarball.
- `chmod +x install.sh scripts/*` fixed executable permissions from the GitHub archive.
- `scripts/download-firefox-esr` downloaded and extracted Firefox ESR ARM64 from Mozilla.

Known issue:

- Board-side `wget` could not download the GitHub archive because of a TLS reset.
- Mozilla Firefox download with board-side `wget` worked.

## Uninstall

```powershell
adb shell "systemctl disable board-browser-ui.service 2>/dev/null || true; systemctl disable board-time-sync.service 2>/dev/null || true; rm -f /etc/systemd/system/board-browser-ui.service; rm -f /etc/systemd/system/board-time-sync.service; rm -f /etc/board-open-firefox; rm -f /etc/board-time-sync; rm -rf /data/local/tmp/board-browser-kit; systemctl daemon-reload 2>/dev/null || true"
```
