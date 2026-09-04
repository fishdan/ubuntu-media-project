# Quickstart: DualSense Controller

Keep SSH connected and Kodi visible on the attached monitor.

## 1. Install support

```bash
sudo scripts/install-dualsense-support.sh
```

## 2. Pair with BlueZ

Put the DualSense in pairing mode by holding Create and PS until its light flashes rapidly. In an interactive `bluetoothctl` session:

```text
power on
agent on
default-agent
scan on
pair <session-local-controller-address>
trust <session-local-controller-address>
connect <session-local-controller-address>
scan off
```

Do not paste the address into repository files or progress history.

## 3. Validate native input

```bash
scripts/dualsense-report.sh
sudo evtest
jstest /dev/input/js0
```

Confirm button/axis events and `hid_playstation` before applying any remapping.

## 4. Validate Kodi

Start Kodi through `media-home.service`. Confirm D-pad/stick navigation, Cross/select, Circle/back, and playback behavior from the couch. Keep `kodi-send` available as recovery.

## 5. Validate media mode

Use `scripts/dualsense-media-mode.sh on|off|status`. Validate desktop navigation and pointer primitives with media mode on. Turn it off and confirm the native controller remains available. Brave, on-screen keyboard, Steam, and universal-home integration are completed in Specs 009-012.

## 6. Reconnect and reboot

Power the controller off/on and confirm reconnection. Reboot the appliance, power on the controller, and confirm Bluetooth/native/Kodi behavior without repairing.

## Acceptance

Spec 008 completes when pairing, native input, Kodi couch navigation, explicit media-mode control, disconnect/reconnect, reboot, privacy review, and all currently available mappings pass. Later-application mappings remain tracked as staged dependencies.
