#!/bin/zsh
# PowerSaver — maximise battery: dim display + keyboard, disable Bluetooth.
#
# The pre-saver state is captured on FIRST entry only. Re-running while already
# in saver mode re-applies the dimming but must not re-capture: the values on
# screen are the dimmed ones, and saving those would overwrite the settings
# Restore exists to bring back, leaving you stuck at 5% brightness.
#
# The `active` flag is created here rather than by toggle.sh, so that the
# standalone AppleScript entry points keep it in sync too.
SUP="$HOME/.powersaver"
BU="/opt/homebrew/bin/blueutil"
DISP_BIN="$SUP/disp"
KB_BIN="$SUP/kb"
STATE="$SUP/state.env"
FLAG="$SUP/active"

MIN_DISPLAY=0.05   # lowest usable brightness; set 0.0 for full-black

if [ ! -f "$FLAG" ]; then
  CUR_D=$("$DISP_BIN" get 2>/dev/null)
  CUR_K=$("$KB_BIN" get 2>/dev/null)
  CUR_B=$("$BU" --power 2>/dev/null)
  {
    echo "DISP=${CUR_D:-0.5}"
    echo "KEYB=${CUR_K:-0.0}"
    echo "BT=${CUR_B:-1}"
  } > "$STATE"
fi

MSG=""
"$DISP_BIN" set $MIN_DISPLAY 2>/dev/null && MSG="Screen → 5%"
"$KB_BIN" set 0.0 2>/dev/null && MSG="$MSG · keyboard off"
# Probe at apply time rather than reusing the capture above, which does not run
# on a re-entry. A non-zero exit here means blueutil is missing or has not been
# granted Bluetooth access.
if "$BU" --power >/dev/null 2>&1; then
  "$BU" --power 0 2>/dev/null && MSG="$MSG · Bluetooth off"
else
  MSG="$MSG · Bluetooth: allow access, re-run"
fi
LPM=$(pmset -g 2>/dev/null | awk '/lowpowermode/{print $2}')
[ "$LPM" = "1" ] && MSG="$MSG · Low Power ON"

touch "$FLAG"
echo "$MSG"
