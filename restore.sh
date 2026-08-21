#!/bin/zsh
# Restore — undo PowerSaver from saved state.
#
# No-ops when not in saver mode. Without that guard, running this twice would
# re-apply a stale state.env over settings changed by hand since, and would
# leave the `active` flag disagreeing with reality.
#
# The flag is cleared here rather than by toggle.sh, so that the standalone
# AppleScript entry points keep it in sync too.
SUP="$HOME/.powersaver"
BU="/opt/homebrew/bin/blueutil"
DISP_BIN="$SUP/disp"
KB_BIN="$SUP/kb"
STATE="$SUP/state.env"
FLAG="$SUP/active"

if [ ! -f "$FLAG" ]; then
  echo "already normal"
  exit 0
fi

DISP=0.7; KEYB=0.0; BT=1
[ -f "$STATE" ] && source "$STATE"
"$DISP_BIN" set "$DISP" 2>/dev/null
"$KB_BIN" set "$KEYB" 2>/dev/null
"$BU" --power "$BT" 2>/dev/null
rm -f "$FLAG"
PCT=$(printf '%.0f' $(( DISP * 100 )))
echo "Restored · screen ${PCT}% · Bluetooth $([ "$BT" = "1" ] && echo on || echo off)"
