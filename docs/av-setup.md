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
| Receiver power cycle | Owner reports Kodi stayed visible with receiver off and back on | Owner heard both samples after power-on; no audio-service restart needed | Active after cycle | Passed for observed cycle |
| Projector input switch away/back | Owner reports everything good | No separate audio sample confirmation at this step | Active at subsequent check | Input-switch accepted; projector power cycle pending |
| PC-to-receiver HDMI disconnect/reconnect | Owner confirmed picture returned | Owner heard replayed samples; no audio-service restart | Active after reconnect | Passed for observed cycle |

## Resumed AV baseline — September 4, 2026

- The owner reports the receiver connected. Mutter detects one primary HDMI-1 display identified as EPSON PJ, at its preferred 1920×1080 60 Hz and scale 1.0. Exact receiver/projector models and visual acceptance await owner confirmation.
- NVIDIA HDMI ELD is valid and advertises stereo/eight-channel PCM and compressed formats. These are advertised capabilities, not playback acceptance.
- PipeWire initially timed out despite active services. `systemctl --user restart pipewire pipewire-pulse wireplumber` restored responsiveness and automatic selection of the NVIDIA Digital Stereo (HDMI) sink at volume 0.40. No persistent audio setting was changed; root cause and recurrence remain unproven.
- SSH is active over Wi-Fi; Ethernet has no link. Kodi's service remains active.
- Current AC inactivity action is `suspend` with timeout `0`; idle blanking is already disabled by Spec 007. No Spec 005 power change has been applied.
- The AV report now bounds audio queries at five seconds and reports failures instead of hanging.

The owner confirmed Kodi is currently clearly visible on the projector. The observed preferred 1080p60 mode is retained (T005). Played the stock Front_Left.wav and Front_Right.wav voice samples through the default HDMI sink with bounded `pw-play` commands; both returned successfully, but audible receiver confirmation remains pending. These mono samples verify audibility only, not channel assignment.


## Accepted audio and AC power policy

The owner heard both voice samples through the receiver, completing baseline stereo audibility (T006). Multichannel routing and encoded passthrough are not yet tested.

Before T008, AC inactivity action was `suspend`, AC timeout was `0`, and idle delay was `uint32 0`. Apply `scripts/configure-av-power.sh --apply` to explicitly disable automatic AC suspend; verify with `--check`. Restore the recorded action with `--restore-baseline`. This script leaves timeout, manual suspend/shutdown, battery settings, and screen locking unchanged. Idle blanking remains managed by Spec 007's `scripts/configure-kodi-session.sh`.

The receiver off/on test preserved the picture throughout; it does not demonstrate recovery from a lost HDMI connection. Both voice samples replayed successfully after the cycle without restarting audio services.

The owner confirmed both replayed voice samples were audible after receiver power-on. Projector input switching, projector power-cycle, HDMI disconnect/reconnect, and AV-on/off boot acceptance remain pending.

Projector off/on: owner reports picture returned normally. SSH remains active and the NVIDIA HDMI sink is available. Both bounded voice samples replayed successfully after this cycle; explicit listening confirmation is pending.

The owner confirmed sound after projector power-on. T010 is accepted for the observed receiver cycle, projector input switch/power cycle, and HDMI reconnection, with SSH available in post-event checks. Recovery times were not measured. AV-on/off boot acceptance remains outstanding.
