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

- [x] T006 Write `scripts/configure-desktop-home.sh` with idempotent `--apply` and `--revert` modes. It must capture prior values before writing, refuse to overwrite an existing capture, and be safe to run repeatedly.
- [x] T007 Apply projector-distance display settings (text scaling, cursor size) and curate `org.gnome.shell favorite-apps` to the streaming browser, Kodi as an ordinary application, and Kodi. No Steam placeholder was added: `steam.desktop` does not exist until Spec 011 installs it, and a favourite pointing at a missing desktop file renders as a blank tile. Verify `--revert` restores the exact baseline in `plan.md`.
- [x] T008 Confirm the Zuzz desktop entry is present in the desktop's application list and launches the browser from the desktop without a terminal.

## Phase 4 — Roadmap bookkeeping

- [x] T009 Update specification status fields: Spec 007 superseded, Spec 012 retired or reduced to its remaining value, Spec 010 reduced to what Spec 016 will not cover, Spec 011 simplified to launch-from-and-exit-to desktop, and Spec 006 annotated as amended (automatic login retained).
- [x] T010 Update `README.md` and `setup.md` from a Kodi-first home to a desktop-first home, and write `docs/desktop-home.md` covering the home experience, applied settings, and the full revert procedure.

## Phase 6 — Desktop pointer (found during T012 preparation)

- [x] T015 Fix the circular dependency that made the desktop unnavigable: pointer mode was turned on only by the browser launcher and off again when it stopped, so the controller could not reach the launcher that enables it. Added `config/systemd/user/dualsense-desktop-input.service` to turn the mode on at login, added an `on-when-present` mode that waits for the Bluetooth controller and exits cleanly if absent, and removed the mode toggling from `launch-zuzz.sh` along with the now-empty `--restore` and its `ExecStopPost`.
- [x] T016 Fix input-remapper injection, which had never actually worked. `input-remapper-control` printed `Starting injection ... Done` while the daemon rejected the request because `config.json` did not exist and no client had called `set_config_dir`. `dualsense-media-mode.sh` now creates `config.json` with an autoload entry and passes `--config-dir` on every call. Replaced the `status` command's cached-intent report with a real check for the per-device `... forwarded` node, and verified both the on and off states report correctly.
- [x] T017 Add `scripts/install-desktop-home.sh` to install the pointer service and helper symlinks and apply the display settings. Verified idempotent across repeated runs; it never enables `media-home.service`.

## Phase 5 — Validation and acceptance

- [x] T011 Reboot the appliance and confirm the acceptance criteria that depend on boot: automatic login still works, the GNOME desktop is reached, no media application starts automatically, `media-home.service` stays disabled, and SSH plus local TTY recovery are intact.
  Passed. Rebooted 2026-09-05 00:32:11. `media-home.service` has no journal entries at all for this boot,
  so it never attempted to start; no Kodi or Firefox process exists; GDM autologin opened dfish's session
  at 00:32:20 onto an active Wayland session on seat0/tty2; SSH enabled and active; tty1-6 present.
  All three couch settings survived the reboot.
- [ ] T012 Owner acceptance from the couch: the DualSense pointer mode navigates the desktop, launches the streaming browser, and returns to the desktop by closing it, with no keyboard or mouse.
- [x] T013 Validate the documented revert path end to end: re-enable `media-home.service`, confirm Kodi-first startup returns without reinstalling or reconfiguring anything, then disable it again and confirm the desktop-first state is restored.
  Verified without a reboot: enabling started Kodi and `--revert` restored all three settings exactly;
  disabling stopped Kodi and `--apply` restored the couch settings. Confirmed the Kodi bounded-stop
  defect reappears on the way back (`media-home.service` lands in `failed`), which is why the documented
  procedure now includes `systemctl --user reset-failed`.
- [~] T014 Run the standard pre-PR checks (`bash -n` on all scripts, `systemd-analyze --user verify`, `git diff --check`, secret and MAC scans), update `progress.ai` and `handoff.ai`, and prepare the pull request.
  Checks done and clean: `bash -n` on all 14 scripts, both systemd units verify clean, `desktop-file-validate`
  clean, `git diff --check` clean, and private-key/secret/MAC scans across all 27 files changed against `main`
  found nothing. No browser profile, cookie, or credential file is tracked. ShellCheck is not installed, so no
  ShellCheck result is claimed. The pull request itself is held pending T012 owner acceptance.

## Explicitly not in this feature

- Text entry without a physical keyboard. It remains open and belongs to Spec 016, which is itself blocked until the owner's phone platform is known.
- Steam installation and Big Picture validation (Spec 011).
- Removing the Kodi package or deleting Kodi userdata; the retirement must stay reversible.
