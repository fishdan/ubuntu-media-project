# Implementation Plan: Kodi and Local/Network Media

**Branch**: `feature/0.007-kodi-local-network-media` | **Date**: 2026-09-04 | **Spec**: [spec.md](spec.md)

## Summary

Install Ubuntu's Kodi 21.3 packages reproducibly, activate them through the guarded Spec 006 media-home service, validate fullscreen launch/local playback/clean exit on the attached monitor, and add optional systemd NFS automount support after the network-media endpoint is known. Keep runtime userdata and credentials outside Git.

## Technical Context

**Language/Version**: Bash, systemd units, Kodi 21.3, and Markdown on Ubuntu 26.04.1 LTS

**Primary Dependencies**: Ubuntu `kodi`/`kodi-bin` and `kodi-eventclients-kodi-send` packages; optional Ubuntu `nfs-common`; existing `media-home.service`, GNOME Wayland, PipeWire, and OpenSSH

**Storage**: Local media paths and optional NFS automounts; Kodi runtime userdata under `~/.kodi` remains untracked

**Testing**: Package/source validation, shell syntax, service/journal checks, fullscreen visual observation, keyboard navigation, known local media playback, intentional exit, unavailable-NFS boot behavior, reboot, and secret scan

**Target Platform**: `orpheus` on Ubuntu 26.04.1 LTS with an attached temporary 1920×1080 monitor

**Project Type**: Linux media-appliance configuration

**Performance Goals**: Kodi appears promptly after graphical login; unavailable network media does not delay boot or block the UI

**Constraints**: Preserve SSH/GNOME recovery; do not claim DualSense or AV-receiver acceptance; do not commit Kodi profiles, credentials, databases, thumbnails, or server secrets

**Scale/Scope**: One Kodi user/session, local test media, and zero or more explicitly configured NFS media exports

## Constitution Check

- PASS: Work occurs on the Spec 007 feature branch with explicit tasks and recovery gates.
- PASS: Distribution packages are preferred over an unreviewed third-party repository.
- PASS: The Spec 006 startup/disable mechanism remains the recovery boundary.
- PASS: Network shares cannot become boot-critical.
- PASS: Runtime profiles and credentials remain outside version control.
- PASS: Monitor-only acceptance is labeled separately from later controller and AV acceptance.

## Project Structure

```text
scripts/
├── install-kodi.sh
└── configure-nfs-media.sh
config/systemd/system/
├── media.mount.template
└── media.automount.template
docs/
├── kodi.md
└── network-media.md
specs/0/0.007-kodi-local-network-media/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

**Structure Decision**: Keep Kodi package installation separate from optional host-level NFS configuration. Generate path-specific systemd units from reviewed inputs rather than committing a live server/export address prematurely.

## Complexity Tracking

No constitution violations or complexity exceptions are required.
