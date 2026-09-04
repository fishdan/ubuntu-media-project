# Implementation Plan: Hardware Inventory

**Branch**: `feature/0.004-hardware-inventory` | **Date**: 2026-09-04 | **Spec**: [spec.md](spec.md)

## Summary

Create a read-only, repeatable shell report for the installed HP ENVY hardware, then distill its output into tracked documentation that later graphics, AV, storage, networking, Bluetooth, and controller features can cite. Exclude unique identifiers and secrets from tracked output.

## Technical Context

**Language/Version**: Bash on Ubuntu 26.04.1 LTS

**Primary Dependencies**: Standard Ubuntu utilities including `lscpu`, `free`, `lsblk`, `lspci`, `lsusb`, `nmcli`, `bluetoothctl`, `wpctl`, `inxi`, and NVIDIA utilities when present

**Storage**: Git-tracked shell script and Markdown report; no database

**Testing**: Shell syntax validation, repeat execution, command exit/status review, privacy scan, and comparison of documented claims with live command output

**Target Platform**: HP ENVY Desktop 795-00xx running Ubuntu 26.04.1 LTS

**Project Type**: Linux appliance installation/configuration documentation

**Performance Goals**: Complete the read-only report in under one minute under normal host conditions

**Constraints**: Do not change drivers or hardware configuration; do not track serial numbers, MAC addresses, IP addresses, UUIDs, credentials, or raw logs containing them; preserve SSH and the graphical desktop

**Scale/Scope**: One appliance; CPU, memory, firmware/model, storage, GPU, network, Bluetooth, USB, audio, and relevant drivers

## Constitution Check

- PASS: Work occurs on a non-`main` feature branch.
- PASS: The live host, rather than auction assumptions, is authoritative.
- PASS: Collection is read-only and does not risk SSH, networking, or desktop recovery.
- PASS: The report script and interpreted inventory are version controlled and repeatable.
- PASS: Unique machine identifiers and credentials are explicitly excluded.

## Project Structure

```text
scripts/
└── hardware-report.sh
docs/
└── hardware.md
specs/0/0.004-hardware-inventory/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

**Structure Decision**: Keep collection logic in one small read-only script and maintain the reviewed, stable findings in `docs/hardware.md`. Raw transient output is not committed.

## Complexity Tracking

No constitution violations or complexity exceptions are required.
