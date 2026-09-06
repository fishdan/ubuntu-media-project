# Tasks: Steam Big Picture

Ordered per `plan.md`. **T005 must precede T008**: the PS button rework has to be
proven against the existing browser path before Steam depends on it, or a
regression there would be discovered from the couch rather than from a shell.

## Phase 1 — Install

- [ ] T001 Record the pre-change baseline: Steam absent, `i386` not enabled, GPU and driver, free disk, session type, and that SSH and the desktop are healthy.
- [ ] T002 Write `scripts/install-steam.sh`: idempotent, enables the `i386` architecture, installs `steam-installer` from Ubuntu `multiverse` only, no third-party APT source, and refuses to run as the wrong user. Verify by running it twice.
- [ ] T003 Complete Steam's first-run bootstrap, which downloads Valve's own client. Record what it pulls and note that the running client self-updates outside APT.

## Phase 2 — Return home must work first

- [ ] T004 Rework `scripts/return-home.sh` to close transient `app-gnome-*.scope` units as well as the existing fixed unit list. Keep the mechanism general, since Spec 017 needs it for dock-launched Brave.
- [ ] T005 **Verify the rework against the existing browser path before Steam uses it.** Start `zuzz-media.service`, confirm the PS button still stops it, and confirm a dock-launched application is also closed. A regression here would break an accepted Spec 015 criterion.

## Phase 3 — Launch and controller hand-off

- [ ] T006 Write `scripts/launch-steam.sh`: turn DualSense media mode **off**, launch Steam into Big Picture, and restore media mode when Steam exits — including on abnormal exit, so the desktop is never left without a pointer.
- [ ] T007 Add a tracked desktop entry and put Steam in the dock through `configure-desktop-home.sh`, so the change stays in version control.
- [ ] T008 Confirm from a shell that launching Steam turns media mode off and exiting restores it, before asking the owner to test from the couch.

## Phase 4 — Owner acceptance

- [ ] T009 Owner launches Steam from the dock with the DualSense alone and reaches Big Picture.
- [ ] T010 Steam Input sees the DualSense as a native gamepad, with no duplicate or phantom input from input-remapper.
- [ ] T011 Sign in to Steam. Text entry uses the Spec 016 phone input; record whether Steam Guard was required and whether phone input handled it.
- [ ] T012 Install and run one representative test title. **Judge it honestly against a GTX 1060 with 3 GB of VRAM** and record what it actually does, including stutter or unplayability. Do not present a title that does not run well as working.
- [ ] T013 The PS button returns from Steam to the desktop, and the pointer works immediately afterwards.

## Phase 5 — Durability and exit

- [ ] T014 Confirm the arrangement survives a reboot: Steam still launches, media mode still restores, and the PS button still works.
- [ ] T015 Document the removal path — uninstall Steam, revert `i386` — and verify SSH, automatic login, the desktop, and the DualSense are unaffected.
- [ ] T016 Write `docs/steam.md` covering install, the controller hand-off, launching, the honest GPU capability note, the bootstrap and `i386` security notes, and removal.
- [ ] T017 Confirm no Steam credentials, tokens, or library paths are tracked; run the standard pre-PR checks including the secret scan; update `progress.ai` and `handoff.ai`; open the pull request.

## Explicitly not in this feature

- A large game library; one representative title is enough.
- Proton or anti-cheat troubleshooting for specific titles.
- Steam Link, remote play, or streaming from another machine.
- GPU tuning of any kind.
