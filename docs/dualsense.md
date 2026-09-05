# DualSense Controller Setup and Recovery

## Design

- BlueZ stores pairing state outside Git.
- Ubuntu's in-kernel `hid_playstation` driver owns the physical controller.
- Kodi uses native joystick events through `kodi-peripheral-joystick`.
- Input-remapper is reserved for an explicit desktop/browser media mode and must be disabled before future Steam launch.
- SSH and `kodi-send` remain available if local controller input fails.

## Install support

```bash
sudo scripts/install-dualsense-support.sh
```

The script installs only Ubuntu repository packages: Kodi joystick support, input-remapper, evtest, and joystick diagnostics.

## Pair the spare controller

Using a spare controller avoids disrupting an active PS5 session. Hold Create and PS until the controller light flashes rapidly, then pair/trust/connect it in `bluetoothctl`. Treat its Bluetooth address as session-local information and never copy it into Git.

## Recovery

- Stop Kodi remotely with `systemctl --user stop media-home.service` if controller navigation becomes trapped.
- Run `scripts/dualsense-media-mode.sh off` before diagnosing native input; investigate any failure before launching Steam.
- A USB cable can provide temporary native controller input without changing tracked configuration.
- Removing/re-pairing the controller is a last step after driver and BlueZ connection checks.

## Acceptance status

- Ubuntu repository support packages are installed and the signed in-kernel `hid_playstation` module binds to the controller.
- BlueZ reports the controller paired, bonded, trusted, and connected. Its address remains only in BlueZ's host-local state.
- Kodi loads `kodi-peripheral-joystick`, detects the main controller and motion-sensor axes, and accepts native controller navigation.
- The project owner confirmed native joystick operation and automatic reconnection after controller timeout by pressing PS once; no re-pair was required.
- Kodi's firmware notice is advisory. Controller firmware can be updated from a PS5 or Sony's Windows PlayStation Accessories application when convenient.

Run the bounded, privacy-safe report with:

```bash
scripts/dualsense-report.sh
```

Desktop/browser media mode remains intentionally separate and opt-in. Brave, the on-screen keyboard, Steam integration, and universal return-home behavior remain owned by Specs 009-012.

## Explicit desktop media mode

Kodi should use native controller input with this mode off. For GNOME and browser testing:

```bash
scripts/dualsense-media-mode.sh on
scripts/dualsense-media-mode.sh status
scripts/dualsense-media-mode.sh off
```

The left stick moves the pointer; the D-pad emits arrow keys; Cross clicks; Circle emits browser Back; Triangle toggles play/pause; L1/R1 change volume; Create emits Escape; and Options emits Enter. The script installs the address-free tracked preset on first use and refuses to overwrite a locally modified copy. Always turn the mode off before launching Steam so Steam Input receives the native controller alone.


## Reboot acceptance and remaining integration

On September 4, 2026, the owner confirmed the controller reconnects and navigates Kodi after the 19:50 reboot. SSH also recovered and accepted administrator authentication. A later diagnostic snapshot found no connected controller; it does not replace the owner's successful post-reboot test.

Spec 008's current scope is accepted on the attached monitor. Projector/receiver couch acceptance remains deferred to Spec 005.

| Later spec | Required checkpoint |
| --- | --- |
| 009 — Brave | Validate pointer, click, back, playback, and volume in the streaming browser. |
| 010 — Keyboard/pointer | Implement and validate keyboard invocation and text entry. |
| 011 — Steam | Disable media mode, validate native Steam Input and absence of duplicate events, then validate exit. |
| 012 — Return home | Implement a stable home command and validate its controller mapping across applications. |

## Pointer mode is on at the desktop (Spec 015)

Since Spec 015 made the GNOME desktop the appliance's home, pointer mode is no
longer opt-in. `dualsense-desktop-input.service` turns it on at login, waiting up
to 60 seconds for the controller to finish connecting over Bluetooth and exiting
cleanly if it never appears. The browser no longer turns the mode on or off; if
it did, closing the browser would leave the desktop with no pointer.

Turn it off before launching Steam so Steam Input receives the native controller
alone. That remains Spec 011's checkpoint.

## Defect fixed 2026-09-05: injection silently did nothing

`input-remapper-control` printed `Starting injection ... Done` while the daemon
logged:

```
ERROR: "/home/dfish/.config/input-remapper-2/config.json" does not exist
ERROR: Request to start an injectoin before a user told the service about
       their session using set_config_dir
```

The daemon rejects every request until a client names the session's config
directory, and it will not accept that unless `config.json` exists. The CLI
reports success regardless, so the mode appeared to work and never had. Kodi's
controller navigation was unaffected because it used native joystick events
through `kodi-peripheral-joystick`, never this remapping — which is why the gap
went unnoticed while Kodi was the home.

`dualsense-media-mode.sh` now creates `config.json` on first use, records the
autoload entry so the preset reapplies when the controller reconnects, and
passes `--config-dir` on every daemon call.

## Verifying the mode for real

`status` no longer reports intent. It checks for the
`input-remapper DualSense Wireless Controller forwarded` device node, which
exists only while the daemon is actually injecting for this controller. The
generic `input-remapper mouse` and `input-remapper keyboard` nodes are not a
valid signal: they persist once created, whether or not injection is running.

```bash
scripts/dualsense-media-mode.sh status
```

It exits non-zero if the mode was requested but is not injecting, which normally
means the controller disconnected.
