# Tasks: Steam Big Picture

Ordered per `plan.md`. **T005 must precede T008**: the PS button rework has to be
proven against the existing browser path before Steam depends on it, or a
regression there would be discovered from the couch rather than from a shell.

## Phase 1 — Install

- [x] T001 Record the pre-change baseline: Steam absent, `i386` not enabled, GPU and driver, free disk, session type, and that SSH and the desktop are healthy.
- [x] T002 Write `scripts/install-steam.sh`: idempotent, enables the `i386` architecture, installs `steam-installer` from Ubuntu `multiverse` only, no third-party APT source, and refuses to run as the wrong user. Verify by running it twice. Done: `steam-installer 1:1.0.0.85~ds-2build1` installed, +192 packages of
  which 186 are i386; second run reported already-installed.
- [x] T003 Complete Steam's first-run bootstrap, which downloads Valve's own client. Record what it pulls and note that the running client self-updates outside APT.
  Completed during the 2026-09-06 owner session, but never recorded; closed on 2026-10-07 from evidence on
  disk. `~/.steam/debian-installation` exists and holds **8.6 GB**: Valve's client plus
  `SteamLinuxRuntime`, `SteamLinuxRuntime_soldier`, `SteamLinuxRuntime_4`, `Proton - Experimental`,
  `Steamworks Shared`, `Steam Controller Configs`, and the installed titles.
  **The self-update claim is now demonstrated rather than asserted:** the APT package is still
  `steam-installer 1:1.0.0.85~ds-2build1` while the running client reports `buildid=1788652215`. APT's
  version is frozen at the bootstrap and says nothing about the code actually executing, which is exactly
  why the distinction is documented in `docs/steam.md`.

## Phase 2 — Return home must work first

- [x] T004 Rework `scripts/return-home.sh` to close transient `app-gnome-*.scope` units as well as the existing fixed unit list. Keep the mechanism general, since Spec 017 needs it for dock-launched Brave.
  Scopes are systemd-escaped (`app-gnome-brave\x2dbrowser-6048.scope`), so matching uses `systemd-escape`
  on an explicit application allowlist. An allowlist rather than "stop every app scope", because
  `update-notifier` and `evolution-alarm-notify` are app scopes too. Brave also registers a second scope
  under its Chromium identity, so that literal is matched as well or the browser survives.
- [x] T005 **Verify the rework against the existing browser path before Steam uses it.** Start `zuzz-media.service`, confirm the PS button still stops it, and confirm a dock-launched application is also closed. A regression here would break an accepted Spec 015 criterion.
  Verified both paths: dock-launched Brave was closed via both its scopes with background helper scopes and
  `init.scope` untouched, and `zuzz-media.service` was still stopped via the unit path. The no-op case
  reports correctly.

## Phase 3 — Launch and controller hand-off

- [x] T006 Write `scripts/launch-steam.sh`: turn DualSense media mode **off**, launch Steam into Big Picture, and restore media mode when Steam exits — including on abnormal exit, so the desktop is never left without a pointer.
  Implemented as `steam-bigpicture.service` rather than a shell trap. A trap can be killed before it runs;
  `ExecStopPost` is guaranteed even if Steam crashes, which is what prevents a crash leaving the desktop
  with no pointer. Both hooks carry a leading `-` so a disconnected controller cannot block Steam starting
  or leave the unit failed. Big Picture is opened via `steam://open/bigpicture` rather than a flag, since
  the flag was renamed across Steam versions (`-bigpicture`, then `-gamepadui`) while the URL stayed stable.
- [x] T007 Add a tracked desktop entry and put Steam in the dock through `configure-desktop-home.sh`, so the change stays in version control.
  Steam was also added to `return-home.sh`'s unit list. All five dock favourites verified to resolve to real
  desktop files.
- [x] T008 Confirm from a shell that launching Steam turns media mode off and exiting restores it, before asking the owner to test from the couch.
  Verified with the controller connected. Before: `ON (live injection confirmed)`. On unit start:
  `off (controller connected, not injecting)` — the hand-off. On unit stop: back to
  `ON (live injection confirmed)`, with the journal showing `ExecStopPost` reapplying the preset. The unit
  cgroup is torn down cleanly with no orphaned Steam processes.

## Phase 4 — Owner acceptance

- [x] T009 Owner launches Steam from the dock with the DualSense alone and reaches Big Picture. Accepted 2026-09-06. First launch appeared unresponsive because the client bootstrap runs for several minutes with no window; the unit was active and working throughout. This affects first run only.
- [x] T010 Steam Input sees the DualSense as a native gamepad, with no duplicate or phantom input from input-remapper.
  Confirmed from Steam's own logs: `Added HIDAPI device 'DualSense Wireless Controller' VID 0x054c,
  PID 0x0ce6, bluetooth 1, path = /dev/hidraw0, driver = SDL_JOYSTICK_HIDAPI_PS5 (ENABLED)` and
  `Controller using HIDAPI driver`. Platform prerequisites all verified: `steam-devices` udev rules
  installed, `dfish` holds ACLs on `/dev/hidraw0`, `/dev/input/event15` and `/dev/uinput` (so Steam can
  emulate a pad for games that do not use the Steam Input API), `js0` present, `BTN_GAMEPAD` and all eight
  axes advertised, `hid_playstation` and `joydev` loaded, and input-remapper holding no forwarded node.
  A game reporting "no controller detected" is therefore a per-game Steam Input setting, not an appliance
  fault.
- [x] T011 Sign in to Steam. Accepted 2026-09-06: the owner signed in successfully and installed games.
- [x] T012 Install and run one representative test title. **Judge it honestly against a GTX 1060 with 3 GB of VRAM** and record what it actually does, including stutter or unplayability. Do not present a title that does not run well as working.
  Accepted 2026-09-06. The owner played several titles including **Thronefall**, which carries *full*
  controller support and worked well, plus RimWorld and FTL. A 24-minute session peaked at 9.3 GB of system
  memory with no reported problems.
  Honest scope of that result: Thronefall, FTL and RimWorld are all comparatively light titles, so this
  confirms the appliance handles exactly the class of game the GTX 1060's 3 GB of VRAM suits. It is not
  evidence that a modern demanding title would run at projector resolution, and none has been tested.
- [~] T013 The PS button returns from Steam to the desktop, and the pointer works immediately afterwards.
  **Partially verified.** The restore half is proven in real use: at 23:48:19, after the owner quit Steam
  from within Big Picture, `ExecStopPost` ran and the journal records `DualSense desktop media mode: on`.
  The pointer came back automatically with no manual step.
  **Still untested: pressing PS while Steam is running.** The owner exited via Steam's own menu, so
  `return-home` was invoked at 23:48:46 when Steam had already stopped 27 seconds earlier and correctly
  reported "nothing to close". The scope/unit matching for Steam has not yet been exercised from the couch.

## Phase 5 — Durability and exit

- [~] T014 Confirm the arrangement survives a reboot: Steam still launches, media mode still restores, and the PS button still works.
  **Verified after the 2026-09-29 reboot (7 days uptime at the time of checking).** SSH active;
  `media-home.service` still `disabled`/`inactive`; GSConnect still enabled; `steam-bigpicture.service`
  still present as `static`. Steam launched from the unit and reached Big Picture (`uimode=4`) with
  `ActiveState=active`, `Result=success`; stop was clean in 16s with `Result=success`, no surviving
  processes, and the cgroup accounted for 2.4G peak memory.
  **Also proven: a missing controller cannot break the unit.** With the DualSense disconnected,
  `ExecStartPre` logged `Device "DualSense Wireless Controller" is unknown or not an appropriate input
  device` and `ExecStopPost` logged `No DualSense connected; leaving desktop media mode off`, yet the unit
  neither failed nor blocked Steam — the leading `-` on both hooks doing its job. This was designed for in
  T006 but had never been observed.
  **Still untested: the media-mode hand-off itself across a reboot**, because the controller was asleep and
  did not reconnect. The off-on transition requires it and is not being claimed from a disconnected run.
- [~] T015 Document the removal path — uninstall Steam, revert `i386` — and verify SSH, automatic login, the desktop, and the DualSense are unaffected.
  Documented in `docs/steam.md`, including that `dpkg --remove-architecture i386` will refuse while any of
  the 186 i386 packages remain, so `autoremove` must run first, and that the tracked dock favourites and
  `return-home.sh` unit list must be updated too or the configuration would no longer match reality.
  **Deliberately not executed**, because it would destroy a working installation and the owner's installed
  games for a test whose outcome is not in doubt. Recorded as documented-but-unverified rather than
  claimed.
- [x] T016 Write `docs/steam.md` covering install, the controller hand-off, launching, the honest GPU capability note, the bootstrap and `i386` security notes, and removal.
- [x] T017 Confirm no Steam credentials, tokens, or library paths are tracked; run the standard pre-PR checks including the secret scan; update `progress.ai` and `handoff.ai`; open the pull request.
  All checks clean on 2026-10-07. Only the project's own eight Steam files are tracked — launcher, unit,
  desktop entry, docs and spec artifacts; no `loginusers`, `ssfn`, token, `steamid`, or real
  `steamapps` path appears anywhere. No private-key headers, no secret assignments, and **no
  Bluetooth-address-shaped strings**, checked specifically because Spec 016 leaked one before and
  `dualsense-media-mode.sh` prints the controller's address at runtime. All 26 tracked scripts pass
  `bash -n`; `systemd-analyze --user verify` accepts all four units with only the pre-existing unrelated
  `spice-vdagent` warning; `git diff --check` clean. `progress.ai` and `handoff.ai` updated, the latter
  rewritten because it was a month stale and wrongly claimed nothing had been pushed.

## Explicitly not in this feature

- A large game library; one representative title is enough.
- Proton or anti-cheat troubleshooting for specific titles.
- Steam Link, remote play, or streaming from another machine.
- GPU tuning of any kind.
