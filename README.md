# Board Browser Kit

Board Browser Kit installs and configures Mozilla Firefox ESR on the QCS8550
Linux board GUI. The public release is a small online installer: it does not
embed Firefox, Debian libraries, Noto fonts, or GNOME icon themes.

During installation, the board downloads pinned third-party packages from
Mozilla and Debian, verifies every file with SHA-256, and keeps the Debian
license files.

## Quick Install

Run these commands in PowerShell on the PC connected to the board:

```powershell
curl.exe -L -o board-browser-kit-v1.1-online-installer.tar.gz https://github.com/anan1999/board-browser-kit/releases/download/v1.1/board-browser-kit-v1.1-online-installer.tar.gz
adb root
adb push board-browser-kit-v1.1-online-installer.tar.gz /data/local/tmp/
adb shell 'cd /data/local/tmp && rm -rf board-browser-kit && tar -xzf board-browser-kit-v1.1-online-installer.tar.gz && cd board-browser-kit && sh install.sh'
```

The board must have working Ethernet access. The tested installation uses
approximately 700 MB while keeping downloaded archives. After installation,
`/data/local/tmp/board-browser-kit/downloads` can be removed to recover about
185 MB.

## Launch

Open the local browser home page:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox
```

Open a URL:

```powershell
adb shell /data/local/tmp/board-browser-kit/board-open-firefox https://www.youtube.com
```

## Documentation

- [Installation and verification SOP](docs/INSTALL_SOP.md)
- [Third-party software and license notice](THIRD_PARTY_NOTICES.md)

Firefox is a Mozilla product. Board Browser Kit is an independent installation
and compatibility tool and is not published, sponsored, or endorsed by
Mozilla.
