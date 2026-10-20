#!/bin/zsh
# Installs a login item that runs start-postiz.sh every time you log in.
# Usage: ./scripts/install-autostart.sh
set -e
DEST="$HOME/Library/Application Support/postiz-start"   # outside ~/Documents (macOS blocks background access there)
LABEL="com.local.postiz-start"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
mkdir -p "$DEST"
cp "${0:A:h}/start-postiz.sh" "$DEST/start-postiz.sh"; chmod +x "$DEST/start-postiz.sh"
cat > "$PLIST" <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array><string>$DEST/start-postiz.sh</string></array>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>$HOME/Library/Logs/postiz-start.log</string>
  <key>StandardErrorPath</key><string>$HOME/Library/Logs/postiz-start.log</string>
</dict></plist>
PL
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "Installed. It runs at every login; log: ~/Library/Logs/postiz-start.log"
echo "Remove with: launchctl bootout gui/\$(id -u)/$LABEL && rm \"$PLIST\""
