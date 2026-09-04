# Implementation Plan: Automatic Login and Appliance Startup

**Branch**: `feature/0.006-automatic-login-appliance-startup` | **Date**: 2026-09-04 | **Spec**: [spec.md](spec.md)

## Summary

Capture the existing GDM automatic-login state as reproducible configuration, add a systemd user service with a guarded media-home launcher, and validate boot/recovery behavior. The launcher will fail safely to GNOME until Spec 007 installs Kodi; it will not restart-loop or hide the recovery desktop.

## Technical Context

**Language/Version**: Bash, systemd user units, and Markdown on Ubuntu 26.04.1 LTS

**Primary Dependencies**: GDM, GNOME Wayland, systemd user manager, OpenSSH; Kodi is a deferred runtime dependency from Spec 007

**Storage**: Git-tracked scripts, systemd unit, and documentation; deployed user files under `~/.local/bin` and `~/.config/systemd/user`

**Testing**: Shell syntax, idempotent check/apply behavior, `systemd-analyze verify`, user-service execution, reboot login/reconnection, local desktop/TTY recovery, and disable/restore drills

**Target Platform**: Ubuntu 26.04.1 LTS Desktop on `orpheus`

**Project Type**: Linux appliance configuration

**Performance Goals**: Reach the graphical session promptly after boot; media-home startup must not delay SSH or create rapid restart cycles

**Constraints**: Preserve SSH, Wi-Fi fallback, GNOME desktop, local TTY, and password/key recovery; do not install Kodi or change AV settings in this feature

**Scale/Scope**: One appliance user (`dfish`), one GDM seat, and one systemd user startup service

## Constitution Check

- PASS: Work is isolated on a non-`main` branch and defined by Spec 006 tasks.
- PASS: SSH and local recovery are explicit gates before reboot.
- PASS: Configuration is represented in version-controlled, idempotent artifacts.
- PASS: Missing Kodi is handled explicitly without claiming the final media UI exists.
- PASS: Automatic startup has independent disable and rollback procedures.

## Project Structure

```text
config/systemd/user/
└── media-home.service
scripts/
├── configure-autologin.sh
├── install-media-startup.sh
└── launch-media-home.sh
docs/
└── startup-recovery.md
specs/0/0.006-automatic-login-appliance-startup/
├── spec.md
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

**Structure Decision**: Separate root-owned GDM configuration from user-owned media startup. The systemd service invokes one guarded launcher and deliberately has no automatic restart policy.

## Complexity Tracking

No constitution violations or complexity exceptions are required.
