#!/bin/zsh
# Toggle: if in saver mode -> restore; else -> enter saver.
#
# The `active` flag is owned by powersave.sh / restore.sh, not by this script.
# Keeping it there means every entry point — this toggle, the menu bar app, and
# the standalone PowerSaver/Restore AppleScripts — agrees on the current mode.
SUP="$HOME/.powersaver"
FLAG="$SUP/active"
if [ -f "$FLAG" ]; then
  OUT=$(/bin/zsh "$SUP/restore.sh")
  echo "☀️ Normal — $OUT"
else
  OUT=$(/bin/zsh "$SUP/powersave.sh")
  echo "🔋 Saver — $OUT"
fi
