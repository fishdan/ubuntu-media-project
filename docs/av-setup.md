# AV Display, Audio, and Power Setup

## Accepted configuration — September 4, 2026

The NVIDIA GeForce GTX 1060 3GB (driver 580.173.02) drives the receiver/projector HDMI path. Mutter identifies one primary `HDMI-1` display as `EPSON PJ`, at its preferred 1920×1080 60 Hz and scale 1.0. The owner confirmed Kodi is clearly visible on the projector. Exact receiver/projector consumer model names were not supplied.

The default audio output is NVIDIA Digital Stereo (HDMI), observed at volume 0.40. The owner heard the stock ALSA voice samples through the receiver. HDMI advertises multichannel and compressed formats, but multichannel routing and encoded passthrough were not tested. Mono voice samples establish audibility, not left/right channel assignment.

SSH remains available over Wi-Fi; Ethernet has no physical link. Kodi and the normal GNOME session remain available.

## Reproduce and recover

Run `scripts/av-report.sh` for read-only session, graphics, audio, and power diagnostics. Audio queries time out after five seconds. `pactl` is unavailable on this host; `wpctl` provides audio state.

The existing preferred display mode and automatic HDMI stereo selection passed testing without a persistent display/audio override. If sound or picture fails, inspect the report before changing configuration. Keep SSH connected and use the temporary monitor on the GPU HDMI output if needed. Stop Kodi through `systemctl --user stop media-home.service` for desktop recovery.

Initially PipeWire queries hung despite active services. `systemctl --user restart pipewire pipewire-pulse wireplumber` restored responsiveness and HDMI selection. This interrupts audio, and is a recovery command rather than a startup requirement. The cause remains unknown; later hot-plug/power tests and the AV-on reboot worked without another audio restart.

## AC power policy and rollback

Before Spec 005 changes, AC inactivity action was `suspend`, AC timeout was `0`, and desktop idle delay was `uint32 0` (already configured by Spec 007).

```bash
scripts/configure-av-power.sh --apply
scripts/configure-av-power.sh --check
# Restore the recorded pre-Spec-005 action:
scripts/configure-av-power.sh --restore-baseline
```

The script changes only the AC inactivity action to `nothing`. Manual suspend/shutdown, battery policy, timeout, and screen locking are unchanged. Spec 007's `scripts/configure-kodi-session.sh` owns idle blanking. The AC action persisted after reboot.

## Acceptance

| Scenario | Result |
| --- | --- |
| Baseline projector and receiver | Owner confirmed picture and audible samples. |
| Receiver off/on | Picture stayed visible; sound worked afterward without audio restart. |
| Projector input away/back | Owner reported everything good. |
| Projector off/on | Owner confirmed picture and replayed sound. |
| PC-to-receiver HDMI disconnect/reconnect | Owner confirmed restored picture and sound without audio restart. |
| AV on at boot | Boot at 20:22:27 EDT; administrator SSH login at 20:23:04; Kodi and HDMI audio started automatically; owner confirmed picture and sound. |
| AV off at boot, then powered on | Skipped at the owner's explicit request on September 4, 2026. Untested, not passed. |

SSH was active in post-event checks. Recovery times were not measured. Receiver standby preserved the picture, so that cycle demonstrates continuity rather than recovery from a lost HDMI connection. The separate cable reconnection test covers an actual disconnect.
