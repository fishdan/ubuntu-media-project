# Plan: Brave streaming

Use Bash, a systemd user service, a desktop entry, Firefox (snap `1:1snap1-0ubuntu8`, reports version 154.0), and Spec 008 input-remapper helpers on Ubuntu GNOME Wayland. Branch: `feature/0.009-brave-zuzz-browser-streaming`.

Originally planned around Brave. Switched to Firefox after owner acceptance testing and a captured `WAYLAND_DEBUG` trace showed Brave/Chromium's Wayland client sends a protocol-correct text-input-v3 focus handshake that GNOME Shell still does not act on, while Firefox triggers the on-screen keyboard correctly on the same page. Firefox was already installed; no new package source was added.

Retain the installed browser package/source. Use `--profile` at `~/.local/share/ubuntu-media-project/firefox-media` with private permissions, launched with `--no-remote --kiosk` and `MOZ_ENABLE_WAYLAND=1` for native-Wayland text-input support. A systemd-owned browser process uses app/fullscreen flags; stop cleanup disables media remapping and restores media-home even if remapping cleanup fails. No automatic startup of the streaming service.

Install symlinks to repository scripts and an owned unit/desktop entry, documenting that the checkout must remain in place. Controller media mode starts only when a connected DualSense is detected; keyboard/mouse remain available for initial account setup. Do not read the personal browser profile or collect credentials.

Validation: Bash syntax, unit verification, isolated mocked failure/cleanup tests, deployment idempotence, owner-visible launch/playback/exit checks, privacy scan. Recovery: stop zuzz-media.service via SSH. Constitution satisfied by tracked changes, branch isolation, explicit recovery, and pending human acceptance.
