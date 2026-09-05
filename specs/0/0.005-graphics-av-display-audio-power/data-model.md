# Data Model: AV Configuration Evidence

This feature records operational state rather than application data.

## Display Path

- GPU and active driver
- DRM connector and connection state
- Display/receiver EDID identity when available
- Selected resolution, refresh rate, scaling, and primary-display role
- GNOME session type and monitor configuration location

## Audio Path

- GPU HDMI audio controller
- PipeWire cards, profiles, sinks, and default sink
- Receiver-visible audio playback result
- Reboot persistence result

## Power Policy

- Original and selected AC suspend settings
- Original and selected idle/blanking delay
- Manual shutdown/suspend recovery path

## Recovery Matrix

- Receiver/projector on at boot
- Receiver/projector off at boot
- Receiver power cycle after login
- Projector/input power cycle after login
- HDMI disconnect/reconnect
- SSH availability and local GNOME recovery for each case

## Validation

Detected state and human-observed behavior are recorded separately. A software check cannot substitute for visible video or audible receiver playback.
