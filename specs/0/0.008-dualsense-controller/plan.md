# Implementation Plan: DualSense Controller

**Branch**: `feature/0.008-dualsense-controller` | **Date**: 2026-09-04 | **Spec**: [spec.md](spec.md)

## Summary

Pair the DualSense with BlueZ, validate the kernel Sony driver and native input events, enable Kodi's packaged joystick support, and build a reversible media remapping layer for GNOME/Brave use. Preserve native controller input for Kodi and future Steam by making the remapper mode explicit and independently disableable.

## Technical Context

**Language/Version**: Bash, input-remapper 2.2.0 presets, systemd, Kodi 21.3, BlueZ, and Markdown on Ubuntu 26.04.1 LTS

**Primary Dependencies**: In-kernel `hid_playstation`; Ubuntu `kodi-peripheral-joystick`, `input-remapper`, `evtest`, and `joystick` packages; existing Kodi/media-home and SSH recovery

**Storage**: BlueZ pairing state outside Git; reviewed scripts/preset templates and documentation in Git; no Bluetooth addresses or unique identifiers tracked

**Testing**: BlueZ trust/connect checks, kernel-driver/input enumeration, `evtest`/`jstest`, Kodi couch navigation, disconnect/reconnect, reboot, remapper enable/disable, and later Brave/Steam integration checkpoints

**Target Platform**: `orpheus` with Realtek Bluetooth 4.2 and a Sony DualSense controller

**Project Type**: Linux media-appliance input configuration

**Performance Goals**: Reconnect and become usable shortly after controller power-on; pointer/navigation input must feel responsive from the couch

**Constraints**: Do not track Bluetooth MAC addresses; do not replace native `hid_playstation`; avoid double input in Kodi/Steam; preserve SSH recovery; Brave, on-screen keyboard, Steam, and return-home implementations are later specs

**Scale/Scope**: One primary DualSense, one Kodi session, one explicit media remap mode, and future handoffs to Brave/keyboard/Steam/home specs

## Constitution Check

- PASS: Work is isolated on the Spec 008 feature branch and based on captured Bluetooth hardware evidence.
- PASS: Pairing secrets and unique controller identifiers remain outside Git.
- PASS: Native controller behavior is tested before adding a remapping layer.
- PASS: Remapping has an explicit disable path to protect Steam Input.
- PASS: Couch-side results and SSH recovery are mandatory.
- PASS: Dependencies on later features are labeled rather than falsely accepted.

## Project Structure

```text
scripts/
├── install-dualsense-support.sh
├── dualsense-media-mode.sh
└── dualsense-report.sh
config/input-remapper/
└── dualsense-media.json.template
docs/
└── dualsense.md
specs/0/0.008-dualsense-controller/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

**Structure Decision**: Keep BlueZ's device-specific pairing state untracked. Prefer Kodi's native joystick layer in Kodi, reserve input-remapper for desktop/browser media mode, and expose explicit on/off commands for future Steam launch wrappers.

## Complexity Tracking

No constitution violations or complexity exceptions are required.
