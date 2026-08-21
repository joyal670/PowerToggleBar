#!/bin/zsh
# PowerSaver — maximise battery: dim display + keyboard, disable Bluetooth. Saves prior state.
SUP="$HOME/.powersaver"
BU="/opt/homebrew/bin/blueutil"
DISP_BIN="$SUP/disp"
KB_BIN="$SUP/kb"
STATE="$SUP/state.env"

MIN_DISPLAY=0.05   # lowest usable brightness; set 0.0 for full-black

CUR_D=$("$DISP_BIN" get 2>/dev/null)
CUR_K=$("$KB_BIN" get 2>/dev/null)
CUR_B=$("$BU" --power 2>/dev/null)
{
  echo "DISP=${CUR_D:-0.5}"
  echo "KEYB=${CUR_K:-0.0}"
  echo "BT=${CUR_B:-1}"
} > "$STATE"

MSG=""
"$DISP_BIN" set $MIN_DISPLAY 2>/dev/null && MSG="Screen → 5%"
"$KB_BIN" set 0.0 2>/dev/null && MSG="$MSG · keyboard off"
if [ -n "$CUR_B" ]; then
  "$BU" --power 0 2>/dev/null && MSG="$MSG · Bluetooth off"
else
  MSG="$MSG · Bluetooth: allow access, re-run"
fi
LPM=$(pmset -g 2>/dev/null | awk '/lowpowermode/{print $2}')
[ "$LPM" = "1" ] && MSG="$MSG · Low Power ON"
echo "$MSG"
