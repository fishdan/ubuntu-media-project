# Steam Big Picture

Steam launches from the desktop into Big Picture, takes the DualSense as a native
gamepad, and hands the pointer back when it exits.

See `specs/0/0.011-steam-big-picture/` for the specification.

## Install

```bash
scripts/install-steam.sh
```

Idempotent. It enables the `i386` architecture, installs `steam-installer` from
Ubuntu `multiverse`, and deploys the launcher, systemd unit and desktop entry.
No third-party APT source is added.

Two things a tidy installer can hide, so they are stated plainly:

- **It enables `i386`.** Steam needs a parallel 32-bit library stack. The install
  added **192 packages, 186 of them i386**, widening the installed surface
  system-wide.
- **`steam-installer` is a bootstrap.** Ubuntu ships the launcher and libraries;
  the Steam client itself is downloaded from Valve on first run and self-updates
  outside APT. "Installed from the Ubuntu repository" describes the package, not
  the software that ends up executing.

### First run looks broken and is not

The first launch downloads and extracts Valve's client for several minutes while
showing **no window at all**. The unit is active and working the whole time.
Check with:

```bash
systemctl --user status steam-bigpicture.service
journalctl --user -u steam-bigpicture.service -f
```

Sign-in needs text entry — use the phone/tablet remote input (`docs/phone-input.md`),
which also covers any Steam Guard code.

## The controller hand-off

Spec 008 established that input-remapper's media mode must be **off** before
Steam starts, or Steam Input sees remapped keyboard and mouse events instead of a
gamepad. Spec 015 then turned that mode **on at login**, because the desktop
needs a pointer. Steam therefore always starts in the wrong state.

`steam-bigpicture.service` resolves it automatically:

| Hook | Action |
| --- | --- |
| `ExecStartPre` | `dualsense-media-mode off` — hands the raw controller to Steam |
| `ExecStopPost` | `dualsense-media-mode on-when-present` — returns the pointer |

**This is a systemd unit rather than a shell trap on purpose.** A trap can be
killed before it runs. If Steam crashed with media mode off, a missed restore
would leave the desktop with no pointer and no keyboard, on a machine designed to
need neither. `ExecStopPost` runs however Steam exits.

Both hooks carry a leading `-`, so a disconnected controller cannot stop Steam
launching or leave the unit failed.

## Launching and returning

Launch **Steam Big Picture** from the dock, or:

```bash
systemctl --user start steam-bigpicture.service
```

Big Picture is opened with `steam://open/bigpicture` rather than a command-line
flag, because the flag has been renamed across versions (`-bigpicture`, then
`-gamepadui`) while the URL has stayed stable.

**The PS button returns to the desktop** — `return-home.sh` stops
`steam-bigpicture.service`, and the pointer comes back through `ExecStopPost`.
Quitting from Steam's own menu does the same thing. Note the PS button repeats
while held, so several invocations may appear in the journal; the script is
idempotent and later runs simply report nothing to close.

## Controller troubleshooting

If a game reports no controller, check the platform first, then the game.

The platform is working if all of these hold:

```bash
grep -i 'HIDAPI device' ~/.steam/steam/logs/console_log.txt   # DualSense added, driver ENABLED
ls /dev/input/js0                                             # joystick node present
getfacl /dev/uinput | grep dfish                              # needed for emulated pads
scripts/dualsense-media-mode.sh status                        # must be "off" while Steam runs
```

`/dev/uinput` matters specifically: without write access Steam cannot synthesise
the virtual gamepad that games not using the Steam Input API rely on, which
presents exactly as "no controller detected".

If all of the above are healthy, the problem is the game's **Steam Input mode**,
set per title in Big Picture under Controller Options:

- **Steam Input enabled** — Steam captures the DualSense and gives the game a
  virtual gamepad.
- **Steam Input disabled** — the game must read the raw device itself.

A game that detects nothing in one mode will often detect a pad in the other. A
title advertising *partial* controller support is a poor test; prefer one with
full support.

## What this hardware can actually play

The GPU is a **GTX 1060 with 3 GB of VRAM**. VRAM, not shader performance, is the
first thing to run out.

Verified working: **Thronefall** (full controller support), **FTL** and
**RimWorld**, over a 24-minute session peaking at 9.3 GB of system memory.

Those are all comparatively light titles. This confirms the appliance suits that
class of game. **It is not evidence that a demanding modern title runs at
projector resolution**, and none has been tested.

## Storage

Steam and a small library used about **9 GB** (5 GB of it games), leaving 192 GB
free of 233 GB.

## Credentials

Steam credentials, tokens, controller configs and the game library all live under
`~/.steam/`. **None of it is tracked**, and nothing from there should be copied
into the repository. Note that some filenames there embed the controller's
Bluetooth address, which the constitution keeps out of version control.

## Removal

```bash
# 1. Remove the package and the launcher pieces
sudo apt-get remove --purge steam-installer steam-libs steam-libs-i386
systemctl --user disable --now steam-bigpicture.service
rm -f ~/.local/bin/launch-steam \
      ~/.config/systemd/user/steam-bigpicture.service \
      ~/.local/share/applications/steam-bigpicture.desktop
systemctl --user daemon-reload

# 2. Optionally reclaim the 32-bit stack
sudo apt-get autoremove --purge
sudo dpkg --remove-architecture i386   # only after autoremove clears i386 packages
sudo apt-get update

# 3. Optionally delete the library and credentials (this removes installed games)
rm -rf ~/.steam ~/.local/share/Steam
```

Also remove `steam-bigpicture.desktop` from the dock favourites in
`scripts/configure-desktop-home.sh`, and Steam from `return-home.sh`'s unit list,
so the tracked configuration matches reality.

Removing Steam does not affect SSH, automatic login, the desktop, GSConnect, or
the DualSense pointer mode.

> **Not verified end to end.** The removal steps above were not executed, because
> doing so would destroy a working installation and the owner's installed games
> for a test whose outcome is not in doubt. `dpkg --remove-architecture i386` in
> particular will refuse while any i386 package remains installed, so run the
> `autoremove` first.
