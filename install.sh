#!/usr/bin/env sh
set -eu

KIT="${BOARD_BROWSER_KIT_DIR:-/data/local/tmp/board-browser-kit}"
INSTALL_SYSTEM="${BOARD_BROWSER_INSTALL_SYSTEM:-1}"
INSTALL_RUNTIME="${BOARD_BROWSER_INSTALL_RUNTIME:-1}"
DISABLE_UPDATES="${BOARD_BROWSER_DISABLE_FIREFOX_UPDATES:-1}"
SELF_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

echo "Board Browser Kit installer"
echo "Source: $SELF_DIR"
echo "Install path: $KIT"

if [ "$SELF_DIR" != "$KIT" ]; then
  echo "Installing kit files to $KIT ..."
  mkdir -p "$KIT"
  cp -R "$SELF_DIR"/. "$KIT"/
fi

cd "$KIT"

# GitHub tar archives and some board tar implementations may not preserve
# executable bits. Normalize the bundled runtime before checking the binary.
chmod -R 755 "$KIT/firefox-esr" "$KIT/firefox-libs" "$KIT/debian-runtime" "$KIT/fontconfig" "$KIT/fonts" 2>/dev/null || true
chmod +x "$KIT"/board-* "$KIT"/download-* 2>/dev/null || true

if [ ! -e "$KIT/board-open-firefox" ] && [ -e "$KIT/scripts/board-open-firefox" ]; then
  echo "Normalizing repository layout ..."
  cp "$KIT/scripts/board-open-firefox" "$KIT/board-open-firefox"
  cp "$KIT/scripts/board-network-up" "$KIT/board-network-up"
  cp "$KIT/scripts/board-time-sync" "$KIT/board-time-sync"
  cp "$KIT/scripts/download-firefox-esr" "$KIT/download-firefox-esr" 2>/dev/null || true
  cp "$KIT/scripts/download-board-runtime" "$KIT/download-board-runtime" 2>/dev/null || true
  cp "$KIT/scripts/debian_package_manifest.py" "$KIT/debian_package_manifest.py" 2>/dev/null || true
  cp "$KIT/scripts/extract_deb_data.py" "$KIT/extract_deb_data.py" 2>/dev/null || true
  cp "$KIT/scripts/board-memory-snapshot" "$KIT/board-memory-snapshot" 2>/dev/null || true
  cp "$KIT/scripts/board-memory-monitor" "$KIT/board-memory-monitor" 2>/dev/null || true
  cp "$KIT/services/board-browser-ui.service" "$KIT/board-browser-ui.service"
  cp "$KIT/services/board-time-sync.service" "$KIT/board-time-sync.service"
  cp "$KIT/ui/board-firefox-home.html" "$KIT/board-firefox-home.html"
  chmod +x "$KIT"/board-* "$KIT"/download-* "$KIT"/*.py 2>/dev/null || true
fi

required_files="
board-open-firefox
board-network-up
board-time-sync
board-browser-ui.service
board-time-sync.service
board-firefox-home.html
download-firefox-esr
download-board-runtime
debian_package_manifest.py
extract_deb_data.py
"

for f in $required_files; do
  if [ ! -e "$KIT/$f" ]; then
    echo "ERROR: missing required file: $KIT/$f"
    exit 1
  fi
done

echo "Preparing board network ..."
"$KIT/board-network-up" || true

if [ ! -x "$KIT/firefox-esr/firefox/firefox" ] && [ -x "$KIT/download-firefox-esr" ]; then
  echo "Firefox binary not found. Downloading Firefox ESR from Mozilla..."
  "$KIT/download-firefox-esr"
fi

if [ ! -x "$KIT/firefox-esr/firefox/firefox" ]; then
  echo "ERROR: Firefox binary not found: $KIT/firefox-esr/firefox/firefox"
  echo "Run this command first:"
  echo "  $KIT/download-firefox-esr"
  exit 1
fi

runtime_gtk="$KIT/debian-runtime/usr/lib/aarch64-linux-gnu/libgtk-3.so.0"
if [ "$INSTALL_RUNTIME" = "1" ] && [ ! -e "$runtime_gtk" ]; then
  echo "GTK runtime not found. Downloading required Debian ARM64 packages..."
  "$KIT/download-board-runtime"
fi

if [ ! -e "$runtime_gtk" ] && [ ! -e /usr/lib/libgtk-3.so.0 ] && [ ! -e /usr/lib/aarch64-linux-gnu/libgtk-3.so.0 ]; then
  echo "ERROR: Firefox GTK runtime is not available."
  echo "Run this command:"
  echo "  $KIT/download-board-runtime"
  exit 1
fi

if [ "$DISABLE_UPDATES" = "1" ] && [ -f "$KIT/policies.json" ]; then
  echo "Applying tested-board Firefox update policy..."
  mkdir -p "$KIT/firefox-esr/firefox/distribution"
  cp "$KIT/policies.json" "$KIT/firefox-esr/firefox/distribution/policies.json"
elif [ "$DISABLE_UPDATES" != "1" ]; then
  rm -f "$KIT/firefox-esr/firefox/distribution/policies.json"
fi

# Never carry a partially downloaded update into a new installation.
rm -rf "$KIT/firefox-esr/firefox/updates"
rm -f "$KIT/firefox-esr/firefox/active-update.xml"

chmod -R 755 "$KIT"

if [ "$INSTALL_SYSTEM" = "1" ]; then
  echo "Installing command wrappers ..."
  cp "$KIT/board-open-firefox" /etc/board-open-firefox
  cp "$KIT/board-time-sync" /etc/board-time-sync
  chmod 755 /etc/board-open-firefox /etc/board-time-sync

  echo "Installing systemd services ..."
  cp "$KIT/board-browser-ui.service" /etc/systemd/system/board-browser-ui.service
  cp "$KIT/board-time-sync.service" /etc/systemd/system/board-time-sync.service
  chmod 644 /etc/systemd/system/board-browser-ui.service /etc/systemd/system/board-time-sync.service

  if command -v systemctl >/dev/null 2>&1; then
    systemctl daemon-reload || true
    systemctl enable board-time-sync.service || true
    systemctl enable board-browser-ui.service || true
  fi

  echo "Installing post-boot time sync hook ..."
  if [ -f /etc/init.post_boot.sh ]; then
    cp -n /etc/init.post_boot.sh /etc/init.post_boot.sh.before-board-browser-kit 2>/dev/null || true
    if ! grep -q '/etc/board-time-sync' /etc/init.post_boot.sh; then
      cat >> /etc/init.post_boot.sh <<'EOF'

if [ -x /etc/board-time-sync ]; then
	( sleep 10; /bin/sh /etc/board-time-sync ) &
fi
EOF
      chmod 755 /etc/init.post_boot.sh
    fi
  fi
else
  echo "Skipping /etc and systemd installation because BOARD_BROWSER_INSTALL_SYSTEM=$INSTALL_SYSTEM"
fi

echo "Running network check ..."
"$KIT/board-network-up" || true

if [ "$INSTALL_SYSTEM" = "1" ]; then
  echo "Running time sync check ..."
  /etc/board-time-sync || true
fi

echo
echo "Board Browser Kit installation completed."
echo
echo "Manual launch:"
echo "  $KIT/board-open-firefox"
echo
echo "Manual launch with URL:"
echo "  $KIT/board-open-firefox https://www.google.com"
echo
echo "Check services:"
echo "  systemctl status board-browser-ui.service"
echo "  systemctl status board-time-sync.service"
