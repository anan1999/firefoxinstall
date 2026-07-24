# Board Browser Kit Installation SOP

## 1. Purpose and Distribution Model

This SOP installs Mozilla Firefox ESR on the QCS8550 Linux board and starts it
directly on the board's Wayland GUI. The browser does not run on, or stream
back to, the connected PC. ADB is used only to transfer the installer and run
board-side commands.

The public Board Browser Kit package contains only:

- Installation, launch, network, time-sync, and memory-monitoring scripts
- A local browser home page
- systemd service definitions
- The Board Browser Kit Wayland compatibility source and ARM64 binary
- A pinned manifest of upstream package URLs and SHA-256 values
- Documentation and license notices

It does not contain Firefox, Debian packages, Noto fonts, or GNOME icon themes.
The board downloads those files from upstream servers during installation.
See `THIRD_PARTY_NOTICES.md` before delivering a configured browser to a
customer.

## 2. Requirements

Board requirements:

- Linux aarch64
- Root access through ADB
- Active Ethernet connection
- Working DNS and default route
- `sh`, `wget` or `curl`, `tar`, `xz`, `python3`, and `sha256sum`
- Weston/Wayland socket at `/run/user/root/wayland-1`
- At least 700 MB free under `/data/local/tmp`

PC requirements:

- ADB
- `curl.exe`
- Access to GitHub

## 3. Upstream Downloads

| Component | Pinned version | Upstream source | Purpose |
| --- | --- | --- | --- |
| Firefox ESR | 140.12.0esr, Linux aarch64, en-US | `https://archive.mozilla.org/pub/firefox/releases/140.12.0esr/` | Browser engine and GUI |
| GTK runtime | Debian Buster ARM64 package set | `https://archive.debian.org/debian/` | GTK, ATK, Cairo, X11 compatibility libraries |
| Noto CJK | Debian `fonts-noto-cjk` | `https://archive.debian.org/debian/` | Traditional Chinese and CJK text rendering |
| Icon themes | Debian `adwaita-icon-theme` and `hicolor-icon-theme` | `https://archive.debian.org/debian/` | GTK toolbar and dialog icons |

Firefox 140.12.0esr is pinned because a later tested ESR build sent an
`xdg_toplevel.set_min_size` request that the board's Weston compositor
rejected. Package paths, versions, and SHA-256 values are recorded in:

```text
manifests/debian-buster-arm64.txt
```

The tested board's `wget` reports that TLS certificate validation is not
implemented. Therefore, the installer does not trust hashes downloaded in the
same session. Firefox and Debian package hashes are pinned inside Board Browser
Kit, and installation stops if a downloaded file does not match.

## 4. Install Through ADB

Run on the Windows PC:

```powershell
curl.exe -L -o board-browser-kit-v1.1-online-installer.tar.gz https://github.com/anan1999/board-browser-kit/releases/download/v1.1/board-browser-kit-v1.1-online-installer.tar.gz
adb root
adb push board-browser-kit-v1.1-online-installer.tar.gz /data/local/tmp/
adb shell 'cd /data/local/tmp && rm -rf board-browser-kit && tar -xzf board-browser-kit-v1.1-online-installer.tar.gz && cd board-browser-kit && sh install.sh'
```

The final command runs on the Linux board. Keep it inside single quotes in
PowerShell so expressions such as `$VAR` are interpreted by the board shell,
not by PowerShell.

The installer performs these operations:

1. Normalizes GitHub archive file permissions and repository layout.
2. Brings up `eth0`, requests DHCP, and repairs the default route if needed.
3. Downloads Firefox ESR from Mozilla and verifies its pinned SHA-256.
4. Downloads the pinned Debian ARM64 packages and verifies every SHA-256.
5. Extracts package payloads into a private runtime without modifying the root
   filesystem package database.
6. Retains Debian copyright files under
   `debian-runtime/usr/share/doc/<package>/copyright`.
7. Builds a local gdk-pixbuf loader cache and fontconfig configuration.
8. Installs launch/time helpers and optional systemd services.
9. Removes pending Firefox updater files and applies the tested update policy.

## 5. GUI and Compatibility Configuration

`board-open-firefox` loads `/etc/profile.d/qim-sdk.sh` when it exists, then
applies the board-specific browser environment:

| Setting | Purpose |
| --- | --- |
| `XDG_RUNTIME_DIR` | Points applications to the runtime directory containing the Wayland socket. |
| `WAYLAND_DISPLAY=wayland-1` | Selects the Weston display used by the board GUI. |
| `MOZ_ENABLE_WAYLAND=1` and `GDK_BACKEND=wayland` | Makes Firefox and GTK render directly through Wayland. |
| `LD_LIBRARY_PATH` | Adds the private Debian GTK runtime before the board's system libraries. |
| `GDK_PIXBUF_MODULE_FILE` | Selects the generated image-loader cache for PNG, JPEG, and other GTK images. |
| `XDG_DATA_DIRS` | Makes GTK find the downloaded Adwaita and hicolor icon themes. |
| `FONTCONFIG_FILE` | Makes fontconfig scan the downloaded Noto CJK font directory. |
| `HOME`, `XDG_CACHE_HOME`, `XDG_CONFIG_HOME` | Keeps browser data under the kit directory instead of the board's system root home. |
| `MOZ_DISABLE_*_SANDBOX` | Avoids namespace and permission incompatibilities on this embedded Linux image. This reduces browser isolation and must be included in the product security review. |
| `LD_PRELOAD=libwayland_resize_guard.so` | Filters Wayland resize requests that the tested Weston compositor rejects. The corresponding C source is included under `compat/`. |

The Firefox update policy is enabled by default:

```text
BOARD_BROWSER_DISABLE_FIREFOX_UPDATES=1
```

This prevents an automatic upgrade to an untested build that may break the
board's Weston compatibility. Set the variable to `0` before `install.sh` to
omit this policy, but validate the newer Firefox build before customer use.

The browser systemd service includes:

```text
SELinuxContext=system_u:system_r:unconfined_t:s0-s15:c0.c1023
```

This asks systemd to run the service in the board's permitted unconfined
SELinux domain. Without the correct domain, SELinux can deny execution of
Firefox stored under `/data/local/tmp`. The exact policy is image-specific and
must be reviewed if the production SELinux policy changes.

## 6. Launch and Verify

Open the local home page:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox
```

Open an external site:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.google.com
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.youtube.com
```

Network and time:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-network-up
adb shell ping -c 2 google.com
adb shell /etc/board-time-sync
adb shell date
```

Firefox processes:

```powershell
adb shell "ps -ef | grep firefox | grep -v grep"
```

Services:

```powershell
adb shell systemctl status board-browser-ui.service
adb shell systemctl status board-time-sync.service
```

One-time memory snapshot:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-memory-snapshot
```

Continuous CSV memory log:

```powershell
adb shell "/data/local/tmp/board-browser-kit/board-memory-monitor 5 /tmp/board-memory-monitor.csv >/tmp/board-memory-monitor.log 2>&1 &"
adb pull /tmp/board-memory-monitor.csv .
```

The clean online-install smoke test on July 24, 2026 verified:

- Mozilla and Debian downloads completed on the board.
- All pinned SHA-256 checks passed.
- 45 Debian packages were extracted and their license files retained.
- The local gdk-pixbuf cache, Noto CJK fonts, and icon themes initialized.
- Firefox ESR Build ID `20260609153453` opened Google on Wayland.
- Main, Socket, RDD, Utility, WebExtensions, and Web Content processes stayed
  running.
- A memory snapshot reported approximately 466 MB RSS for the main Firefox
  process during the Google test; total usage changes with pages and tabs.

Non-fatal log warnings may include missing PCI GPU detection, accessibility
DBus, and unavailable `/dev/video0` or `/dev/video1`.

## 7. Disk Cleanup

After a successful installation, downloaded archives are no longer required:

```powershell
adb shell "rm -rf /data/local/tmp/board-browser-kit/downloads"
```

This recovered approximately 185 MB in the tested installation. Do not remove
`firefox-esr` or `debian-runtime`.

## 8. Uninstall

```powershell
adb shell "systemctl disable board-browser-ui.service 2>/dev/null || true; systemctl disable board-time-sync.service 2>/dev/null || true; rm -f /etc/systemd/system/board-browser-ui.service /etc/systemd/system/board-time-sync.service /etc/board-open-firefox /etc/board-time-sync; rm -rf /data/local/tmp/board-browser-kit; systemctl daemon-reload 2>/dev/null || true"
```
