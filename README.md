# PowerToggleBar

A macOS menu-bar battery saver. One click drops the machine into a low-power
state — display dimmed, keyboard backlight off, Bluetooth off — and a second
click puts everything back exactly as it was.

```
🔋 Saver  — Screen → 5% · keyboard off · Bluetooth off · Low Power ON
☀️ Normal — Restored · screen 70% · Bluetooth on
```

The point is the **restore**. Dimming a screen is trivial; what is annoying is
remembering what your brightness and Bluetooth were before you dimmed them.
This captures that state on the way in and replays it on the way out.

## What it's for

- Stretching the last stretch of battery on a flight, a commute, or a long
  meeting away from a charger
- A single deliberate action instead of four separate trips through Control
  Centre and System Settings
- Getting your exact previous setup back without thinking about it

The display is the dominant power draw on a laptop, so brightness is doing most
of the work here; the keyboard backlight and Bluetooth radio are smaller but
free to reclaim.

## How it works

The menu-bar app is a thin trigger. All the real work is three zsh scripts and
two tiny Swift helpers, coordinated through a flag file:

```
menu bar click
   └─► toggle.sh
         ├─ ~/.powersaver/active exists?  ──► restore.sh ──► rm active   → "Normal"
         └─ otherwise                     ──► powersave.sh ──► touch active → "Saver"
```

**`toggle.sh`** is the entry point, and it is stateless apart from the flag —
the presence or absence of `~/.powersaver/active` *is* the mode.

**`powersave.sh`** reads current display brightness, keyboard backlight, and
Bluetooth power, writes all three to `state.env`, then sets brightness to
`MIN_DISPLAY` (0.05), keyboard backlight to 0.0, and Bluetooth off. It also
reports whether macOS Low Power Mode is on, read from `pmset -g` — it does not
set it, since that needs elevated privileges.

**`restore.sh`** sources `state.env` and replays all three values. If the file is
missing it falls back to sane defaults (`DISP=0.7`, `KEYB=0.0`, `BT=1`) rather
than failing, so a lost state file leaves you with a usable screen instead of a
black one.

### The brightness helpers

macOS exposes no public API for either display or keyboard brightness, so each
helper reaches into a private framework via `dlopen`/`dlsym`:

| Helper | Framework | Symbols |
|---|---|---|
| `disp.swift` | `DisplayServices` | `DisplayServicesGetBrightness` / `…SetBrightness` on `CGMainDisplayID()` |
| `kb.swift` | `CoreBrightness` | `KeyboardBrightnessClient` → `brightnessForKeyboard:` / `setBrightness:forKeyboard:` |

Both take the same shape — `disp get` prints the current value, `disp set 0.5`
writes one — and both fail soft: if the framework or symbol cannot be resolved
they print a default and exit `0`, so the toggle degrades instead of hanging.

**This is the fragile part of the project.** Private frameworks carry no
compatibility guarantee and can change or vanish in any macOS release. The
fail-soft behaviour means a break shows up as brightness silently not changing,
not as a crash.

Bluetooth goes through [`blueutil`](https://github.com/toy/blueutil), which is a
normal public tool.

## Requirements

- macOS 13 or later, Apple Silicon (paths assume `/opt/homebrew`)
- `blueutil` — `brew install blueutil`
- Xcode command line tools for `swiftc`

Without `blueutil` the toggle still runs; brightness and keyboard are handled
normally and the message reads `Bluetooth: allow access, re-run`.

## Layout

| Piece | Location |
|---|---|
| App bundle | `~/Applications/PowerToggleBar.app` (`com.joyal.powertogglebar`) |
| Autostart | `~/Library/LaunchAgents/com.joyal.powertogglebar.plist` (`RunAtLoad`) |
| Runtime install | `~/.powersaver` — **must stay there** |
| This repository | Source copies, under version control |

### Runtime coupling — read before moving anything

Every script hard-codes `SUP="$HOME/.powersaver"`, and the app invokes
`$HOME/.powersaver/toggle.sh`. That directory is the **live install**, not a
build output, and it holds state that must not be committed:

- `active` — flag file; present means saver mode is on
- `state.env` — the brightness/keyboard/Bluetooth values captured on entry
- `disp`, `kb` — compiled binaries

This repository holds *copies* for version control. Editing a script here has no
effect until it is copied across.

## Setup

### From a clean machine

```bash
brew install blueutil

mkdir -p ~/.powersaver
cp *.sh *.applescript *.icns ~/.powersaver/
chmod +x ~/.powersaver/*.sh

swiftc -O disp.swift -o ~/.powersaver/disp
swiftc -O kb.swift   -o ~/.powersaver/kb
```

Verify the helpers before wiring up anything else:

```bash
~/.powersaver/disp get     # expect a float such as 0.7
~/.powersaver/kb get       # expect a float such as 0.0
~/.powersaver/toggle.sh    # should flip the display and print a status line
```

If `disp get` prints exactly `0.5` and brightness never changes, the private
framework lookup is failing — see the caveat above.

### Applying edits made in this repository

```bash
cp ~/Developer/PowerToggleBar/*.sh ~/.powersaver/
swiftc -O ~/Developer/PowerToggleBar/disp.swift -o ~/.powersaver/disp
swiftc -O ~/Developer/PowerToggleBar/kb.swift   -o ~/.powersaver/kb
```

### Autostart

The LaunchAgent runs the menu-bar app at login:

```bash
launchctl load ~/Library/LaunchAgents/com.joyal.powertogglebar.plist
launchctl list | grep powertoggle
```

## The AppleScripts

Three standalone entry points, each shelling out to one script and reporting the
result as a notification. They are an alternative to the menu-bar app — useful
as Shortcuts actions, Automator quick actions, or hotkeys:

| Script | Runs | Notification |
|---|---|---|
| `PowerToggle.applescript` | `toggle.sh` | ⚡ Power Toggle |
| `PowerSaver.applescript` | `powersave.sh` | 🔋 PowerSaver — Battery optimized |
| `Restore.applescript` | `restore.sh` | ☀️ Restore — Back to normal |

Compile one into a clickable app with:

```bash
osacompile -o ~/Applications/PowerToggle.app PowerToggle.applescript
```

## Tuning

`MIN_DISPLAY` at the top of `powersave.sh` sets how far the screen dims.
Default `0.05` is the lowest still-usable brightness; `0.0` is full black.

## Notes and limitations

- **Private frameworks.** Display and keyboard brightness rely on unsupported
  APIs that may break on a macOS upgrade.
- **Bluetooth permission.** The first `blueutil` run may prompt for access; the
  toggle reports this and works on the retry.
- **Low Power Mode is reported, not set** — changing it requires privileges this
  does not ask for. Set it in System Settings → Battery.
- **The app binary has no source.** `PowerToggleBar.app/Contents/MacOS/PowerToggleBar`
  is a compiled Mach-O with no matching Swift source anywhere on the machine.
  `PowerToggle.applescript` implements equivalent logic and can rebuild a
  working menu-bar entry point via `osacompile`, but it is not what produced the
  shipped bundle. Anyone cloning this repository gets the scripts, not that app.
- **State survives a reboot.** If you reboot while in saver mode, `active` and
  `state.env` persist, so the next toggle correctly restores your original
  settings rather than the dimmed ones.
