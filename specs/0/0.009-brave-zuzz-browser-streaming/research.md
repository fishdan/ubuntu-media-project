# Research

Observed installed `brave-browser` package 1.94.121; executable reports Brave Browser 152.1.94.121. APT source uses Brave's release repository with a dedicated signed-by keyring.

Chromium documents separate user-data directories: https://chromium.googlesource.com/chromium/src/+/HEAD/docs/user_data_dir.md . A dedicated directory isolates media logins from personal browsing. App/fullscreen behavior must be checked on the actual Brave/Wayland session.

Prefer systemd process-group ownership and ExecStopPost recovery over killing all Brave processes. Keep browser sandbox and site protections enabled. Any site-specific DRM/login problem requires observation before changing settings.

## GNOME on-screen keyboard incompatibility with Brave/Chromium (2026-09-04)

Owner acceptance testing on the actual GNOME Wayland session showed the on-screen keyboard (enabled via `org.gnome.desktop.a11y.applications screen-keyboard-enabled`) appears correctly for native GTK dialogs (the keyring-unlock prompt) but never for Brave's own web-content text fields, across three attempts: baseline, `--enable-wayland-ime --wayland-text-input-version=3`, and additionally `--force-renderer-accessibility`.

A `WAYLAND_DEBUG=1` capture of a manual Brave instance (same flags) while the owner tapped a Zuzz field showed Brave correctly binding `zwp_text_input_manager_v3` and sending the full expected `zwp_text_input_v3` handshake on focus (`enter`, `enable`, `set_content_type`, `set_cursor_rectangle`, `set_surrounding_text`, `commit`). This rules out a missing/incorrect Brave launch flag: Brave's client-side protocol behavior looks correct, but GNOME Shell does not react to it by showing the keyboard. A public Brave community report of the identical symptom on Ubuntu found no resolution before its thread auto-closed, consistent with an unresolved upstream Brave/Chromium-Wayland or GNOME Shell interaction rather than a local misconfiguration.

A side-by-side test with the already-installed snap Firefox (`154.0`) launched as `firefox --kiosk https://zuzz.tv` with `MOZ_ENABLE_WAYLAND=1` showed the on-screen keyboard appearing correctly and immediately in a Zuzz text field. This confirms the failure is Brave/Chromium-specific rather than a blanket GNOME Shell defect, and is the basis for switching this feature's browser from Brave to Firefox.

Firefox kiosk launching: `--kiosk` gives an app-style, chrome-less fullscreen window equivalent to Brave's `--app=` behavior. `--profile <dir> --no-remote` gives an isolated, persistent, non-default profile directory (unlike `--private-window`, which does not persist logins across relaunch, so it cannot satisfy this feature's close/relaunch session-persistence requirement).
