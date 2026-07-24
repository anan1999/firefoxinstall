#!/usr/bin/env sh
set -eu

KIT="${BOARD_BROWSER_KIT_DIR:-/data/local/tmp/board-browser-kit}"
INSTALL_SYSTEM="${BOARD_BROWSER_INSTALL_SYSTEM:-1}"
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
chmod -R 755 "$KIT/firefox-esr" "$KIT/firefox-libs" "$KIT/fontconfig" "$KIT/fonts" 2>/dev/null || true
chmod +x "$KIT"/board-* "$KIT/download-firefox-esr" 2>/dev/null || true

if [ ! -e "$KIT/board-open-firefox" ] && [ -e "$KIT/scripts/board-open-firefox" ]; then
  echo "Normalizing repository layout ..."
  cp "$KIT/scripts/board-open-firefox" "$KIT/board-open-firefox"
  cp "$KIT/scripts/board-network-up" "$KIT/board-network-up"
  cp "$KIT/scripts/board-time-sync" "$KIT/board-time-sync"
  cp "$KIT/scripts/download-firefox-esr" "$KIT/download-firefox-esr" 2>/dev/null || true
  cp "$KIT/scripts/board-memory-snapshot" "$KIT/board-memory-snapshot" 2>/dev/null || true
  cp "$KIT/scripts/board-memory-monitor" "$KIT/board-memory-monitor" 2>/dev/null || true
  cp "$KIT/services/board-browser-ui.service" "$KIT/board-browser-ui.service"
  cp "$KIT/services/board-time-sync.service" "$KIT/board-time-sync.service"
  cp "$KIT/ui/board-firefox-home.html" "$KIT/board-firefox-home.html"
  chmod +x "$KIT"/board-* "$KIT/download-firefox-esr" 2>/dev/null || true
fi

required_files="
board-open-firefox
board-network-up
board-time-sync
board-browser-ui.service
board-time-sync.service
board-firefox-home.html
"

for f in $required_files; do
  if [ ! -e "$KIT/$f" ]; then
    echo "ERROR: missing required file: $KIT/$f"
    exit 1
  fi
done

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
