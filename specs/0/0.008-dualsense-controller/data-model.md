# Data Model: DualSense Controller State

This feature records operational state rather than application data.

## Pairing State

- Controller model/name
- Bluetooth paired, bonded, trusted, and connected status
- Reconnect and reboot results
- Bluetooth address excluded from tracked records

## Native Input State

- `hid_playstation` driver binding
- Input/event and joystick device presence
- Button, axis, touchpad, motion, battery, LED, and force-feedback capabilities where exposed
- Kodi joystick add-on recognition

## Media Mapping State

- Reviewed input-remapper preset version
- Explicit enabled/disabled mode
- Navigation, select, back, playback, volume, pointer, click, keyboard-hook, and home-hook mappings
- Native-input handoff state for Kodi and Steam

## Acceptance State

- Kodi couch navigation result
- Bluetooth disconnect/reconnect result
- Reboot reconnect result
- Brave, keyboard, Steam, and return-home checkpoints completed or explicitly deferred

## Validation

Mapped behavior must not strand the user without SSH recovery. Unique controller identifiers and BlueZ pairing files remain untracked.
