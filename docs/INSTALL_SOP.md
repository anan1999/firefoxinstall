# Board Browser Kit GitHub Install SOP

This package installs Firefox ESR on the board so the browser runs directly on
the board GUI.

Repository:

```text
https://github.com/anan1999/firefoxinstall
```

## Package

Publish this file as a GitHub Release asset:

```text
board-browser-kit-v1.0.tar.gz
```

Use GitHub Releases for this package because the Firefox runtime may be too
large for normal Git repository files.

## Online Install From GitHub

Run these commands on the board:

```sh
cd /data/local/tmp
wget -O board-browser-kit-v1.0.tar.gz https://github.com/anan1999/firefoxinstall/releases/download/v1.0/board-browser-kit-v1.0.tar.gz
tar -xzf board-browser-kit-v1.0.tar.gz
cd board-browser-kit
chmod +x install.sh
./install.sh
```

If `wget -O` is not supported, use:

```sh
cd /data/local/tmp
curl -L -o board-browser-kit-v1.0.tar.gz https://github.com/anan1999/firefoxinstall/releases/download/v1.0/board-browser-kit-v1.0.tar.gz
tar -xzf board-browser-kit-v1.0.tar.gz
cd board-browser-kit
chmod +x install.sh
./install.sh
```

## Offline Install Through ADB

Run these commands on the PC:

```powershell
adb root
adb push board-browser-kit-v1.0.tar.gz /data/local/tmp/
adb shell "cd /data/local/tmp && tar -xzf board-browser-kit-v1.0.tar.gz && cd board-browser-kit && chmod +x install.sh && ./install.sh"
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
