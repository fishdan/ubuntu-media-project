# Zuzz media browser setup

Firefox (snap `1:1snap1-0ubuntu8`, reports version 154.0) was already installed on the appliance. No browser package or personal profile was changed.

This feature originally launched Brave. Owner acceptance testing found that GNOME's on-screen keyboard never appears for Brave/Chromium web-content text fields, even with Wayland IME and forced-accessibility flags. A captured Wayland protocol trace showed Brave sending a protocol-correct `text-input-v3` focus handshake that GNOME Shell still does not act on, while a side-by-side Firefox test showed the keyboard working immediately on the same page. The owner chose to switch the launcher to Firefox rather than keep pursuing the Brave/GNOME incompatibility. See `progress.ai` (2026-09-04 entries) for the full diagnostic trail.

Run `scripts/install-browser-media.sh` as the graphical user. The installer deploys the managed `zuzz-media.service` and GNOME Zuzz entry, and links `~/.local/bin/launch-zuzz` to this checkout. Keep the checkout in place; rerun installation if it moves.

Launch with `~/.local/bin/launch-zuzz`. Kodi stops, a connected DualSense enters desktop media mode, and Firefox opens https://zuzz.tv in kiosk mode using a dedicated `zuzz-media` profile, launched with `--no-remote -P zuzz-media` so it never touches the owner's default Firefox profile. Do not open that profile through a separate unmanaged Firefox process.

The profile is addressed by name rather than by path on purpose. Snap-confined Firefox is denied by AppArmor from creating its profile lock files (`.parentlock`, `lock`) under an arbitrary `--profile` directory, including paths under `$HOME`, and fails silently when that happens. Addressing the profile by name lets Firefox store it inside its own confinement (currently `~/snap/firefox/common/.mozilla/firefox/5dit69wh.zuzz-media`, mode 700). The launcher creates the profile on first run and skips creation when it already exists. The profile is outside Git in either case.

Close the browser normally or run `systemctl --user stop zuzz-media.service` through SSH. Systemd stops only the managed browser process group, attempts to disable remapping, and starts Kodi again. Remapping cleanup failures are reported even though Kodi restoration is still attempted. If input remains remapped, run `scripts/dualsense-media-mode.sh off` and investigate the reported error.

Log in locally; browser data and credentials remain outside Git. Browser sandbox and security settings remain enabled. The launcher does not enable automatic streaming startup.

Controller mapping uses Spec 008 primitives. Kodi menu integration and universal controller Home belong to Spec 012. Streaming/login and projector acceptance remain pending until the owner confirms them on the Firefox-based launcher.

Disable/remove this integration by stopping `zuzz-media.service`, removing its installed unit, the Zuzz desktop entry, and the launch-zuzz symlink, then running `systemctl --user daemon-reload`. Keep the private media profile unless you explicitly intend to delete stored logins.

The now-unused `~/.local/share/ubuntu-media-project/brave-media` profile directory from the earlier Brave-based launcher was left in place rather than deleted automatically; remove it manually if you do not intend to return to Brave.

## Keyring prompt and on-screen keyboard

The owner confirmed the controller's native touchpad can focus text fields, and GNOME's on-screen keyboard works both for the first-launch keyring prompt and directly in Firefox's website fields:

```bash
gsettings set org.gnome.desktop.a11y.applications screen-keyboard-enabled true
```

This setting remains enabled. Restore the prior setting with the same command using `false`. Enter the keyring password locally; keyring protection remains enabled.
