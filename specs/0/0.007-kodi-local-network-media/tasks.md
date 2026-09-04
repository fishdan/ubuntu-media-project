---
description: "Task list for Kodi and Local/Network Media"
---

# Tasks: Kodi and Local/Network Media

**Input**: Design documents from `specs/0/0.007-kodi-local-network-media/`

**Tests**: Command checks and human-visible monitor/playback checks in `quickstart.md` are mandatory.

## Phase 1: Planning and Baseline

- [x] T001 Confirm Ubuntu package availability and create the Spec 007 plan, research, data model, quickstart, and tasks.
- [ ] T002 Record current Kodi/NFS package, SSH, GNOME, audio, and `media-home.service` baseline evidence.
- [ ] T003 Confirm whether an NFS media source is in current scope and collect only the required server/export/local-path/read-only decisions.

## Phase 2: Kodi Installation

- [ ] T004 Create and validate idempotent `scripts/install-kodi.sh` using Ubuntu repository packages.
- [ ] T005 Install Kodi and verify version, package source, executable, and startup-service integration.
- [ ] T006 Visually confirm fullscreen launch and basic keyboard navigation on the attached monitor.
- [ ] T007 Play known local media, record video/audio results and current audio limitation, then intentionally exit to GNOME.

## Phase 3: Optional Network Media

- [ ] T008 If NFS is in scope, create reviewed mount/automount templates and an idempotent configuration script; otherwise record the explicit deferral.
- [ ] T009 If configured, validate successful on-demand mounting, permissions, and Kodi access without committing credentials or runtime profile data.
- [ ] T010 If configured, validate unavailable-server and reboot behavior; otherwise mark not applicable with the owner's scope decision.

## Phase 4: Reboot and Recovery

- [ ] T011 Reboot after preflight checks and confirm SSH, automatic GNOME login, media-home startup, fullscreen Kodi, and intentional return to GNOME.
- [ ] T012 Validate the documented remote disable/restore recovery path with Kodi installed.

## Phase 5: Completion

- [ ] T013 Re-run the quickstart, scan for secrets/Kodi runtime data, update documentation and `.config/ai/progress.ai`, and mark Spec 007 complete.

## Dependencies

- T002 and T003 precede installation or NFS configuration.
- T004 precedes T005-T007.
- T003 determines whether T008-T010 are implemented or explicitly not applicable.
- T006 and T007 require human-visible confirmation.
- T011 follows local acceptance and any NFS failure test.
- T013 depends on all in-scope acceptance tasks.
