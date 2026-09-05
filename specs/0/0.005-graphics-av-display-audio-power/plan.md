# Implementation Plan: Graphics, AV Display, HDMI Audio, and Power

**Branch**: `feature/0.005-graphics-av-display-audio-power` | **Date**: 2026-09-04 | **Spec**: [spec.md](spec.md)

## Summary

Inspect the active NVIDIA/Wayland display and PipeWire audio paths, connect the GPU through the AV receiver to the projector, select validated modes and HDMI audio, apply narrowly scoped plugged-in power settings, and prove recovery across hot-plug, AV power cycles, and boots. Keep SSH and a local GNOME recovery path available throughout.

## Technical Context

**Language/Version**: Bash and Markdown on Ubuntu 26.04.1 LTS

**Primary Dependencies**: NVIDIA driver 580.173.02, GNOME Wayland/Mutter, DRM sysfs, PipeWire 1.6.2, WirePlumber, `wpctl`, `pactl`, `gsettings`, and systemd-logind

**Storage**: Git-tracked scripts and Markdown evidence; GNOME and PipeWire user configuration

**Testing**: Read-only command checks plus human-visible projector, receiver-audio, power-cycle, hot-plug, and reboot acceptance tests

**Target Platform**: HP ENVY 795-00xx with NVIDIA GeForce GTX 1060 3GB connected GPU HDMI → AV receiver → projector

**Project Type**: Linux appliance installation/configuration

**Performance Goals**: Restore usable video and audio within 30 seconds of normal AV power/hot-plug events

**Constraints**: Preserve SSH, Wi-Fi fallback, normal GNOME recovery, and the NVIDIA driver; do not assume EDID modes or audio sinks; do not disable all power management globally

**Scale/Scope**: One GNOME user session, one NVIDIA HDMI path, one AV receiver, and one projector

## Constitution Check

- PASS: Work is isolated on a non-`main` branch and follows an active specification.
- PASS: GPU and driver choices come from Spec 004 live evidence.
- PASS: SSH, graphical recovery, and rollback commands are mandatory.
- PASS: Couch-side AV behavior requires human-visible acceptance.
- PASS: Persistent settings will be documented and kept narrowly scoped.

## Project Structure

```text
scripts/
└── av-report.sh
docs/
└── av-setup.md
specs/0/0.005-graphics-av-display-audio-power/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

**Structure Decision**: Use one read-only report script for repeatable diagnostics and one AV setup/recovery guide for reviewed settings and acceptance evidence. Any setting-changing automation requires a task and explicit rollback.

## Complexity Tracking

No constitution violations or complexity exceptions are required.
