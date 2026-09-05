# Tasks: Brave streaming

- [x] T001 Verify installed Brave and signed package source; define spec, plan, and acceptance scope.
- [x] T002 Implement private-profile launcher, managed service, desktop entry, and idempotent installer with SSH recovery.
- [x] T003 Validate syntax, unit, failure cleanup, and repeated installation before visible launch.
- [ ] T004 Launch on projector; owner confirms presentation, login, streaming audio/video, and controller navigation.
- [ ] T005 Validate normal close, administrator stop, Kodi restoration, and media-profile login persistence on relaunch.
- [ ] T006 Review privacy, documentation, and progress; prepare PR after current-scope acceptance.

- [x] T007 Resolve first-launch keyring interaction without a physical keyboard using temporary GNOME accessibility input; preserve keyring protection and record rollback. Full controller keyboard integration remains Spec 010.

- [x] T008 Enable and validate Brave Wayland text-input support for GNOME on-screen keyboard in website fields. (Superseded — root-caused in T009 and resolved by switching browsers in T010; the added Wayland IME flags did not fix Brave.)

- [x] T009 Diagnose browser keyboard activation with installed GNOME/Chromium input code; test GTK4 media launch and verify field focus, typing, and backspace without changing credential storage. (Captured a WAYLAND_DEBUG trace proving Brave sends a protocol-correct text-input-v3 focus handshake that GNOME Shell still does not act on; a side-by-side Firefox test confirmed the on-screen keyboard works there. See `research.md` and `progress.ai` 2026-09-04 entries.)

- [x] T010 Replace Brave with Firefox as the Zuzz browser at the owner's direction: rewrote `scripts/launch-zuzz.sh` and `scripts/install-browser-media.sh` for a private Firefox `--profile`/`--kiosk` launch, renamed the managed unit to `zuzz-media.service`, updated the desktop entry and `docs/browser-media.md`. Bash syntax and unit validation pass.

- [x] T012 Validate the managed launch path after the snap profile fix: started `zuzz-media.service`
  and confirmed Firefox runs under the unit with `--no-remote -P zuzz-media --kiosk https://zuzz.tv`
  and the site rendered. Recorded a new defect: stopping `media-home.service` now leaves it `failed`
  because `kodi.bin` survives to the final-sigterm timeout. See `progress.ai` 2026-09-05.

- [ ] T011 Owner acceptance on the new Firefox-based launcher: confirm projector presentation, on-screen-keyboard typing/backspace in a website field, streaming login/playback, close/relaunch account persistence, and Kodi restoration on stop.
