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

The status command reports cached intent, not live injection state. A reboot, controller disconnect, or external remapper command can invalidate that intent. Stop failures propagate to the caller so launch integrations must honor a nonzero exit status.
