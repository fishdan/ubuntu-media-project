---
description: "Task list for Automatic Login and Appliance Startup"
---

# Tasks: Automatic Login and Appliance Startup

**Input**: Design documents from `specs/0/0.006-automatic-login-appliance-startup/`

**Tests**: Command and reboot checks in `quickstart.md` are mandatory.

## Phase 1: Planning and Baseline

- [x] T001 Create the Spec 006 plan, research, data model, quickstart, and tasks.
- [x] T002 Record GDM, display-manager alias, graphical seat, automatic-login, systemd user-manager, and SSH baseline evidence.

## Phase 2: Reproducible Configuration

- [x] T003 Create and test idempotent `scripts/configure-autologin.sh` with check, apply, disable, validation, and backup behavior.
- [x] T004 Create `scripts/launch-media-home.sh` with safe missing-Kodi behavior and no restart loop.
- [x] T005 Create and verify `config/systemd/user/media-home.service` with appropriate graphical-session ordering and explicit logging.
- [x] T006 Create and test idempotent `scripts/install-media-startup.sh` for user-owned deployment and enablement.

## Phase 3: Recovery and Acceptance

- [x] T007 Document and validate independent media-startup disable/restore and automatic-login disable/recovery in `docs/startup-recovery.md`.
- [x] T008 Reboot only after SSH validation; visually confirm automatic GNOME login, reconnect SSH, and confirm graphical seat and safe staged media service.
- [x] T009 Confirm local GNOME and TTY recovery remain usable after reboot.

## Phase 4: Completion

- [x] T010 Run the full quickstart, scan changes for secrets, update `.config/ai/progress.ai`, and mark Spec 006 complete.

## Dependencies

- T002 precedes configuration changes.
- T003-T006 precede recovery drills and reboot.
- T007 precedes T008.
- T008 and T009 require human-visible confirmation.
- T010 depends on all acceptance tasks.
