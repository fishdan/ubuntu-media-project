# Quickstart: Graphics, AV Display, HDMI Audio, and Power

Run commands from an SSH or VS Code Remote SSH session while observing the connected display and receiver locally.

## 1. Capture the safe baseline

```bash
bash -n scripts/av-report.sh
scripts/av-report.sh
```

Record current GNOME power values before changing them:

```bash
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
gsettings get org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
gsettings get org.gnome.desktop.session idle-delay
```

## 2. Connect the AV path

Use GPU HDMI → AV receiver input → receiver HDMI output → projector. Keep SSH connected. Confirm DRM reports the expected HDMI connector as connected, then use GNOME Settings to select the projector's native resolution, appropriate refresh rate, and primary-display role.

## 3. Select and test HDMI audio

Inspect `wpctl status` and `pactl list cards short`. Select the NVIDIA HDMI profile/sink only after the receiver is detected. Play a known local test sound, confirm it is audible through the receiver, and verify the selected sink after reboot.

## 4. Apply deliberate AC power behavior

After recording original values, disable automatic suspend on AC:

```bash
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
```

Set `idle-delay` only after choosing the desired couch behavior. Preserve manual suspend and shutdown. The rollback is to restore the exact values captured in step 1.

## 5. Run the recovery matrix

For every case, confirm picture, audio where applicable, GNOME usability, and SSH:

1. Boot with receiver and projector on.
2. Boot with receiver and projector off, then power them on.
3. Power-cycle the receiver after login.
4. Power-cycle the projector or change away from and back to its input.
5. Disconnect and reconnect HDMI after login.

Record failures precisely. Do not erase GNOME monitor configuration or replace the GPU driver without a new task and recovery plan.

## Acceptance

Spec 005 completes only after native projector video, receiver HDMI audio, power behavior, all recovery-matrix cases, SSH continuity, and rollback documentation pass.
