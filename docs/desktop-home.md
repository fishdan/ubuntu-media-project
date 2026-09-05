# Desktop Home

The appliance boots to the ordinary GNOME desktop. There is no media shell, no
session takeover, and nothing to restore when an application exits.

This replaced a Kodi-first home on 2026-09-05. The owner confirmed the appliance
will never hold a local media library, which left Kodi acting only as a launcher
shell that the desktop already provides. Retiring it deleted the stop/restore
orchestration that had been the appliance's most failure-prone component — it
caused visible faults on multiple occasions, including a `media-home.service`
that ended in a `failed` state on every stop because Kodi's child process
survived to the unit's kill timeout.

See `specs/0/0.015-desktop-first-home/` for the specification, plan, and tasks.

## What happens at boot

1. GDM logs in `dfish` automatically (Spec 006, unchanged).
2. The GNOME Wayland session starts.
3. Nothing else. No media application launches automatically.

`media-home.service` is installed but **disabled**. It is kept only as the
revert path.

## Launching things

| Application | How |
| --- | --- |
| Zuzz streaming | The **Zuzz** launcher, or `~/.local/bin/launch-zuzz` |
| Firefox | The normal Firefox launcher (separate from the media profile) |
| Kodi | The normal Kodi launcher; still installed, just no longer the home |

The dock favourites are curated to Zuzz, Firefox, and Kodi. Steam is added by
Spec 011; it is deliberately absent from the favourites until then, because a
favourite pointing at a missing desktop file renders as a blank tile.

Zuzz runs under `zuzz-media.service`, which exists so an administrator can stop
the browser over SSH:

```
systemctl --user start zuzz-media.service
systemctl --user stop  zuzz-media.service
```

Stopping it now only resets the DualSense controller mapping. It no longer
starts Kodi.

## Controller pointer at the desktop

The desktop is the home, so the DualSense must be able to drive it. Pointer mode
is turned on at login by `dualsense-desktop-input.service`: the left stick moves
the pointer, Cross clicks, the D-pad sends arrow keys, Circle is Back, and L1/R1
change volume.

This is a change from the Kodi era, when pointer mode was opt-in and was switched
on only while the browser ran. That arrangement cannot work with a desktop home:
you would need the pointer to launch the browser, but the pointer only appeared
once the browser had launched, and closing it took the pointer away again. The
browser no longer touches the mode at all.

```bash
scripts/dualsense-media-mode.sh status   # confirms live injection, not intent
scripts/dualsense-media-mode.sh on       # after reconnecting the controller
scripts/dualsense-media-mode.sh off      # required before launching Steam
```

If the controller is not connected at login the service exits cleanly and leaves
the mode off; connect the controller and run `on`. See `docs/dualsense.md` for
the injection defect fixed on 2026-09-05.

## Couch-legible display settings

Applied by `scripts/configure-desktop-home.sh`, which captures the prior value
of everything it writes before writing it:

| Setting | Appliance value | Prior value |
| --- | --- | --- |
| `org.gnome.desktop.interface text-scaling-factor` | `1.5` | `1.0` |
| `org.gnome.desktop.interface cursor-size` | `48` | `24` |
| `org.gnome.shell favorite-apps` | Zuzz, Firefox, Kodi | Ubuntu defaults |
| `dash-to-dock dock-fixed` | `true` | `false` |
| `dash-to-dock autohide` | `false` | `true` |
| `dash-to-dock dash-max-icon-size` | `64` | `48` |

The dock is pinned open deliberately. By default it auto-hides, which means
hunting for a screen edge with a controller stick from across the room.

```
scripts/configure-desktop-home.sh --apply     # configure for the couch
scripts/configure-desktop-home.sh --status    # show current vs desired
scripts/configure-desktop-home.sh --revert    # restore the captured values
```

The rollback baseline is written once to
`~/.local/state/ubuntu-media-project/desktop-home.baseline` and is never
overwritten by a later `--apply`, so it always describes the appliance as it was
before this feature first touched it. `--revert` restores those values and
removes the file.

If the desktop is still hard to read from the couch, raise
`text-scaling-factor` in the script rather than by hand, so the change stays in
version control.

## Installing

```bash
scripts/install-desktop-home.sh
```

Idempotent and safe to re-run. It links the helper scripts into `~/.local/bin`,
installs and enables `dualsense-desktop-input.service`, and applies the display
settings. It never enables `media-home.service`, so re-running it will not undo
the Kodi retirement.

## Reverting to the Kodi-first home

Nothing was uninstalled, so this needs no reinstallation or reconfiguration:

```
systemctl --user enable --now media-home.service
scripts/configure-desktop-home.sh --revert
```

The first command restores Kodi at login. The second restores the original
display settings and dock favourites. Reboot to confirm.

To go back to the desktop-first home:

```
systemctl --user disable --now media-home.service
systemctl --user reset-failed media-home.service
scripts/configure-desktop-home.sh --apply
```

The `reset-failed` is expected and is not a sign of a problem. Kodi's main
process exits on SIGTERM but its `kodi.bin` child survives to the unit's kill
timeout, so stopping `media-home.service` always leaves it in a `failed` state.
This is the defect that motivated the desktop-first change. The desktop-first
appliance never stops the unit, so the failure is only reachable while you are
deliberately switching between the two homes.

Note that `scripts/install-media-startup.sh` installs `media-home.service` but
deliberately leaves it disabled, so re-running the installer will not undo the
retirement. Enablement is now a deliberate act.

## Known limitations

- **GNOME is not a ten-foot interface.** Scaling and large text reduce but do
  not eliminate this.
- **Text entry without a physical keyboard is not solved here.** Spec 009
  established that GNOME's on-screen keyboard depends on application
  cooperation that the browser did not reliably provide. Phone-based remote
  input is Spec 016, which is itself blocked until the owner's phone platform
  is known.
- **No local media library, NFS export, or network mount** is assumed,
  configured, or reintroduced.
