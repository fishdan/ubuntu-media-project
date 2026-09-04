---
description: "Task list for Hardware Inventory"
---

# Tasks: Hardware Inventory

**Input**: Design documents from `specs/0/0.004-hardware-inventory/`

**Tests**: Command-based checks in `quickstart.md` are mandatory.

## Phase 1: Planning and Safety

- [x] T001 Create the Spec 004 plan, research, data model, quickstart, and tasks in `specs/0/0.004-hardware-inventory/`.
- [x] T002 Define privacy exclusions and verify the collection design is read-only in `specs/0/0.004-hardware-inventory/research.md` and `quickstart.md`.

## Phase 2: Repeatable Collection

- [x] T003 [US1] Create `scripts/hardware-report.sh` to report system, CPU, memory, storage, PCI/driver, network, Bluetooth, USB, and audio evidence without unique identifiers.
- [x] T004 [US1] Validate `scripts/hardware-report.sh` with `bash -n`, execute it twice, and confirm it makes no host changes.

## Phase 3: Reviewed Inventory

- [x] T005 [US1] Record the verified system, CPU, memory, firmware, and storage inventory in `docs/hardware.md`.
- [x] T006 [US1] Record GPU, Ethernet, Wi-Fi, Bluetooth, USB, and audio devices plus active drivers in `docs/hardware.md`.
- [x] T007 [US1] Distinguish detected hardware from capabilities still requiring graphics, AV, Bluetooth, or controller acceptance testing in `docs/hardware.md`.

## Phase 4: Validation and Completion

- [x] T008 Run the `quickstart.md` evidence checks and reconcile every claim in `docs/hardware.md`.
- [x] T009 Scan tracked changes for serial numbers, MAC/IP addresses, UUIDs, credentials, private keys, and Wi-Fi secrets; record the result in `.config/ai/progress.ai`.
- [x] T010 Update `.config/ai/progress.ai`, mark Spec 004 complete, and prepare the feature for review.

## Dependencies

- T002 precedes collection.
- T003 precedes T004 and documentation.
- T005 through T007 depend on validated live output.
- T008 and T009 precede T010.
