#!/bin/zsh
# Restore — undo PowerSaver from saved state.
SUP="$HOME/.powersaver"
BU="/opt/homebrew/bin/blueutil"
DISP_BIN="$SUP/disp"
KB_BIN="$SUP/kb"
STATE="$SUP/state.env"

DISP=0.7; KEYB=0.0; BT=1
[ -f "$STATE" ] && source "$STATE"
"$DISP_BIN" set "$DISP" 2>/dev/null
"$KB_BIN" set "$KEYB" 2>/dev/null
"$BU" --power "$BT" 2>/dev/null
PCT=$(printf '%.0f' $(( DISP * 100 )))
echo "Restored · screen ${PCT}% · Bluetooth $([ "$BT" = "1" ] && echo on || echo off)"
