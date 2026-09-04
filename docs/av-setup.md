# AV Display, Audio, and Power Setup

## Current safe baseline

Observed on 2026-09-04 before connecting the permanent AV chain:

- Ubuntu runs an active graphical GNOME session on `seat0`; administration remains available over SSH.
- The NVIDIA GeForce GTX 1060 3GB uses driver 580.173.02.
- DRM reports `card1-HDMI-A-1` connected to the temporary HP 2310 monitor, with modes up to 1920×1080.
- DRM reports the HDMI connector disabled at the instant of the baseline capture, consistent with the currently blanked/inactive display state; this is not yet projector evidence.
- ALSA exposes Intel analog audio and four NVIDIA HDMI playback devices.
- PipeWire detects the Intel and NVIDIA controllers but exposes only `Dummy Output`; receiver audio is not yet available.
- GNOME's AC inactivity action is `suspend`, its AC timeout is `0`, and the desktop idle delay is 300 seconds.

## Intended physical path

```text
NVIDIA GPU HDMI → AV receiver input → AV receiver HDMI output → projector
```

Do not use a motherboard display output for the permanent path. Keep an authenticated SSH connection available while changing cables or AV power.

## Selected persistent settings

No Spec 005 display, audio, or power settings have been changed yet.

## Recovery

- If the picture disappears, keep the host running and inspect `scripts/av-report.sh` through SSH.
- Reconnect the known working temporary monitor to the GPU HDMI port if the receiver/projector chain cannot recover.
- Do not remove the NVIDIA driver or erase GNOME monitor configuration as an initial troubleshooting step.
- Power changes must record their original `gsettings` values here before being applied.

## Acceptance matrix

| Test | Video | Audio | SSH | Result |
| --- | --- | --- | --- | --- |
| Temporary monitor baseline | Detected at up to 1920×1080 | Dummy Output only | Available | Baseline only |
| AV on at boot | Not tested | Not tested | Not tested | Pending |
| AV off at boot, then powered on | Not tested | Not tested | Not tested | Pending |
| Receiver power cycle | Not tested | Not tested | Not tested | Pending |
| Projector/input power cycle | Not tested | Not tested | Not tested | Pending |
| HDMI disconnect/reconnect | Not tested | Not tested | Not tested | Pending |
