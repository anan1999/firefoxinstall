# Board Browser Kit

This repository contains the customer-facing install SOP and board-side scripts
for running Firefox ESR directly on the Linux board GUI.

The browser is launched on the board itself through ADB-installed scripts. It
does not open a browser on the PC or notebook.

## What This Installs

- Firefox ESR runtime for ARM64 Linux boards
- Board launch command: `/data/local/tmp/board-browser-kit/board-open-firefox`
- Local browser home page with quick links and a URL input
- Network recovery helper for `eth0`
- Automatic time sync helper for HTTPS certificate validity
- systemd services for browser launch and time sync
- Memory snapshot and CSV monitoring tools
- Font configuration for Chinese / CJK text rendering
- Wayland runtime workaround used by the tested board image

## Customer Install

Download the full release package from GitHub Releases, then run the installer
on the board:

```sh
cd /data/local/tmp
wget -O board-browser-kit-v1.0.tar.gz https://github.com/anan1999/firefoxinstall/releases/download/v1.0/board-browser-kit-v1.0.tar.gz
tar -xzf board-browser-kit-v1.0.tar.gz
cd board-browser-kit
chmod +x install.sh
./install.sh
```

If `wget` is not available, use `curl -L -o board-browser-kit-v1.0.tar.gz <release-url>`.

## Launch Browser

```sh
/data/local/tmp/board-browser-kit/board-open-firefox
```

Open a specific page:

```sh
/data/local/tmp/board-browser-kit/board-open-firefox https://www.youtube.com
```

## Documentation

See [docs/INSTALL_SOP.md](docs/INSTALL_SOP.md) for the full SOP,
verification commands, memory monitoring commands, and uninstall steps.

## Release Package Note

The Firefox runtime and native libraries are published as a GitHub Release asset
instead of normal Git files. The full package should be named:

```text
board-browser-kit-v1.0.tar.gz
```
