---
description: "Task list for DualSense Controller"
---

# Tasks: DualSense Controller

**Input**: Design documents from `specs/0/0.008-dualsense-controller/`

**Tests**: Kernel/input command checks and human couch-side checks are mandatory.

## Phase 1: Planning and Baseline

- [x] T001 Create the Spec 008 plan, research, data model, quickstart, and tasks after verifying Ubuntu package/driver availability.
- [x] T002 Record the Bluetooth controller, BlueZ, Kodi joystick package, input-remapper, input-device, and SSH recovery baseline without unique addresses.

## Phase 2: Native DualSense

- [x] T003 Create and validate idempotent `scripts/install-dualsense-support.sh` using Ubuntu packages.
- [x] T004 Pair, trust, and connect the DualSense over Bluetooth without recording its address in Git.
- [x] T005 Create `scripts/dualsense-report.sh` with address redaction and validate `hid_playstation`, event/joystick devices, buttons, axes, and available capabilities.
- [x] T006 Install/enable Kodi joystick support and validate native couch navigation with the project owner.

## Phase 3: Explicit Media Mode

- [x] T007 Capture actual DualSense event codes and create a reviewed input-remapper media preset without a hard-coded device address.
- [x] T008 Create `scripts/dualsense-media-mode.sh` with on/off/status behavior and validate desktop controller primitives with the project owner.
- [x] T009 Confirm media mode can be disabled cleanly and native controller events remain available for future Steam Input.

## Phase 4: Reconnect and Recovery

- [x] T010 Validate controller power-off/on reconnection without repairing.
- [x] T011 Reboot and validate Bluetooth reconnection, native input, Kodi navigation, and SSH recovery.
- [x] T012 Record Brave, on-screen-keyboard, Steam, and universal-home mappings as staged checkpoints for Specs 009-012 rather than claiming unavailable integration.

## Phase 5: Completion

- [x] T013 Run privacy/secret scans, reconcile `docs/dualsense.md`, update `.config/ai/progress.ai`, and mark Spec 008 complete.

## Dependencies

- T002-T003 precede pairing.
- T004 precedes native event capture and Kodi testing.
- T005-T006 precede remapping.
- T007 precedes media-mode validation.
- T009 precedes future Steam work.
- T010 precedes reboot acceptance.
- T013 depends on all current-scope acceptance tasks.

## Final review

- [x] T014 Make media-mode stop failures visible and label cached status honestly; validate failure behavior without changing live input.
