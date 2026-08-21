# PowerToggleBar

Menu-bar battery saver. Toggles between "saver" (screen 5%, keyboard backlight off,
Bluetooth off) and "normal" (restores the values captured at the time saver was entered).

## Layout

| Piece | Location |
|---|---|
| App bundle | `~/Applications/PowerToggleBar.app` (`com.joyal.powertogglebar`) |
| Autostart | `~/Library/LaunchAgents/com.joyal.powertogglebar.plist` (`RunAtLoad`) |
| Runtime dir | `~/.powersaver` — **must stay there** |
| Source (this dir) | copies of the scripts, Swift helpers, and icons |

## Runtime coupling — read before moving anything

The scripts hard-code `SUP="$HOME/.powersaver"` and the app invokes
`$HOME/.powersaver/toggle.sh`. That directory is the live install, not a build output:

- `active` — flag file; present means saver mode is on
- `state.env` — brightness/keyboard/Bluetooth values captured on entering saver
- `disp`, `kb` — compiled from `disp.swift` / `kb.swift`

This directory holds *copies* for version control. Editing a script here has no effect
until it is copied back:

```sh
cp ~/Developer/PowerToggleBar/*.sh ~/.powersaver/
```

Rebuild the helpers after editing their sources:

```sh
swiftc -O ~/Developer/PowerToggleBar/disp.swift -o ~/.powersaver/disp
swiftc -O ~/Developer/PowerToggleBar/kb.swift  -o ~/.powersaver/kb
```

## External dependency

`powersave.sh` calls `/opt/homebrew/bin/blueutil` for Bluetooth. If it is missing the
toggle still runs and reports `Bluetooth: allow access, re-run`.

## Missing source

`PowerToggleBar.app/Contents/MacOS/PowerToggleBar` is a compiled binary with no Swift
source anywhere on this machine. `PowerToggle.applescript` here is the equivalent logic
(shells out to `toggle.sh`) but is not what built the shipped bundle.
