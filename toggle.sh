#!/bin/zsh
# Toggle: if in saver mode -> restore & clear flag; else -> save state & enter saver.
SUP="$HOME/.powersaver"
FLAG="$SUP/active"
if [ -f "$FLAG" ]; then
  OUT=$(/bin/zsh "$SUP/restore.sh")
  rm -f "$FLAG"
  echo "☀️ Normal — $OUT"
else
  OUT=$(/bin/zsh "$SUP/powersave.sh")
  touch "$FLAG"
  echo "🔋 Saver — $OUT"
fi
