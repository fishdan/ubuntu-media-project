# Tasks: Desktop-First Home and Kodi Retirement

Ordered per `plan.md`. Steps T002 and T003 must not be reordered: simplifying the
Zuzz launcher before the automatic Kodi launch is retired would restore Kodi on
every browser exit.

## Phase 1 — Retire the automatic Kodi launch

- [x] T001 Capture the pre-change baseline: `media-home.service` enabled/active state, the GNOME settings listed in `plan.md`, and confirmation that SSH and automatic login are currently healthy. Record in `progress.ai`.
- [x] T002 Disable `media-home.service` and reset its failed state. Leave the unit file and `launch-media-home` installed so the revert path needs no reinstallation. Confirm Kodi is not running and the GNOME desktop is present.
- [x] T003 Update `scripts/install-media-startup.sh` to install the launcher and unit without `enable --now`, and to print the revert command. Verify idempotence by running it twice and confirming the unit stays disabled.

## Phase 2 — Remove the stop/restore orchestration

- [x] T004 Remove `systemctl --user stop media-home.service` from `launch-zuzz.sh --run` and `systemctl --user start media-home.service` from `--restore`, leaving `--restore` as the DualSense mode reset only. Keep `zuzz-media.service` as the administrator's SSH-side stop path.
- [x] T005 Validate the simplified launcher: `bash -n`, then start and stop `zuzz-media.service` and confirm Firefox launches and exits without touching `media-home.service`, which must remain disabled and inactive throughout.
  Surfaced a latent defect while validating: `input-remapper-control` exits non-zero when the DualSense is
  not connected, so `ExecStopPost` marked `zuzz-media.service` failed after every clean stop. `--restore` is
  now best-effort and warns instead of propagating. Verified a full stop/start cycle leaves the unit
  `inactive` and `media-home.service` disabled and inactive throughout.

## Phase 3 — Couch-legible desktop

- [ ] T006 Write `scripts/configure-desktop-home.sh` with idempotent `--apply` and `--revert` modes. It must capture prior values before writing, refuse to overwrite an existing capture, and be safe to run repeatedly.
- [ ] T007 Apply projector-distance display settings (text scaling, cursor size) and curate `org.gnome.shell favorite-apps` to the streaming browser, Kodi as an ordinary application, and a placeholder for the future Steam entry. Verify `--revert` restores the exact baseline in `plan.md`.
- [ ] T008 Confirm the Zuzz desktop entry is present in the desktop's application list and launches the browser from the desktop without a terminal.

## Phase 4 — Roadmap bookkeeping

- [ ] T009 Update specification status fields: Spec 007 superseded, Spec 012 retired or reduced to its remaining value, Spec 010 reduced to what Spec 016 will not cover, Spec 011 simplified to launch-from-and-exit-to desktop, and Spec 006 annotated as amended (automatic login retained).
- [ ] T010 Update `README.md` and `setup.md` from a Kodi-first home to a desktop-first home, and write `docs/desktop-home.md` covering the home experience, applied settings, and the full revert procedure.

## Phase 5 — Validation and acceptance

- [ ] T011 Reboot the appliance and confirm the acceptance criteria that depend on boot: automatic login still works, the GNOME desktop is reached, no media application starts automatically, `media-home.service` stays disabled, and SSH plus local TTY recovery are intact.
- [ ] T012 Owner acceptance from the couch: the DualSense pointer mode navigates the desktop, launches the streaming browser, and returns to the desktop by closing it, with no keyboard or mouse.
- [ ] T013 Validate the documented revert path end to end: re-enable `media-home.service`, confirm Kodi-first startup returns without reinstalling or reconfiguring anything, then disable it again and confirm the desktop-first state is restored.
- [ ] T014 Run the standard pre-PR checks (`bash -n` on all scripts, `systemd-analyze --user verify`, `git diff --check`, secret and MAC scans), update `progress.ai` and `handoff.ai`, and prepare the pull request.

## Explicitly not in this feature

- Text entry without a physical keyboard. It remains open and belongs to Spec 016, which is itself blocked until the owner's phone platform is known.
- Steam installation and Big Picture validation (Spec 011).
- Removing the Kodi package or deleting Kodi userdata; the retirement must stay reversible.
