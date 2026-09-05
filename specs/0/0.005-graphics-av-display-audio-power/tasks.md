---
description: "Task list for Graphics, AV Display, HDMI Audio, and Power"
---

# Tasks: Graphics, AV Display, HDMI Audio, and Power

**Input**: Design documents from `specs/0/0.005-graphics-av-display-audio-power/`

**Tests**: Command checks and couch-side human observation in `quickstart.md` are mandatory.

## Phase 1: Planning and Baseline

- [x] T001 Create the Spec 005 plan, research, data model, quickstart, and task list.
- [x] T002 Create the read-only `scripts/av-report.sh` covering session, NVIDIA, DRM connectors/modes, EDID identity when available, PipeWire/PulseAudio, and GNOME power state.
- [x] T003 Validate the report script and record the current monitor/audio/power baseline in `.config/ai/progress.ai` without changing the appliance.

## Phase 2: Physical AV Display

- [x] T004 [US1] Connect GPU HDMI → AV receiver → projector while preserving SSH, and record the detected connector and EDID identity in `docs/av-setup.md`.
- [x] T005 [US1] Select and visually validate native projector resolution, refresh rate, scaling, and primary-display behavior.

## Phase 3: HDMI Audio

- [x] T006 [US2] Select the NVIDIA HDMI audio profile and receiver sink only after detection, then confirm audible playback through the receiver.
- [x] T007 [US2] Reboot and confirm HDMI audio selection and playback persist.

## Phase 4: Power and Recovery

- [x] T008 [US3] Record original power settings, disable automatic suspend on AC, choose the media-session blanking behavior, and document exact rollback commands.
- [x] T009 [US3] AV-on boot passed; AV-off boot before later power-on explicitly waived by owner on 2026-09-04 (untested, not passed).
- [x] T010 [US3] Validate receiver power-cycle, projector/input power-cycle, and HDMI disconnect/reconnect recovery while SSH remains available.

## Phase 5: Completion

- [x] T011 Reconcile the performed acceptance sequence and `docs/av-setup.md`; preserve the owner-approved AV-off boot waiver and observed limitations.
- [x] T012 Review tracked changes for secrets and unique hardware identifiers, update `.config/ai/progress.ai`, and mark Spec 005 complete.

## Dependencies

- T002 and T003 precede all configuration.
- T004 precedes display and audio selection.
- T005 precedes final recovery testing.
- T006 precedes T007.
- T008 records rollback before T009 and T010.
- T009 and T010 require human-visible acceptance and precede completion.

## Resumed diagnostics

- [x] T013 Bound audio report queries so an unresponsive audio service cannot block SSH diagnostics.
