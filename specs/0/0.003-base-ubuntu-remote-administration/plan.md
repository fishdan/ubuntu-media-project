# Implementation Plan: Base Ubuntu and Remote Administration

**Branch**: `feature/0.003-base-ubuntu-remote-administration` | **Date**: 2026-09-04 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/0/0.003-base-ubuntu-remote-administration/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

Validate and document the already-installed Ubuntu 26.04.1 LTS host as the project baseline for the media appliance, then establish recoverable Ethernet/Wi-Fi networking, OpenSSH key authentication, post-reboot SSH access, and VS Code Remote SSH access. Do not reinstall or downgrade the host during this feature.

## Technical Context

**Language/Version**: Shell and Markdown; Ubuntu 26.04.1 LTS host (`resolute`)

**Primary Dependencies**: `openssh-server`, `openssh-client`, NetworkManager, VS Code Remote - SSH; versions selected from Ubuntu repositories

**Storage**: Host filesystem and Git-tracked configuration/documentation; no application database

**Testing**: Command-based acceptance checks, SSH key authentication, reboot reconnection without keyboard/monitor attached, NetworkManager inspection, and VS Code Remote SSH connection

**Target Platform**: Ubuntu Desktop 26.04.1 LTS on the HP ENVY Desktop 795-00XX; local GNOME desktop remains available

**Project Type**: Installation and configuration documentation for a Linux desktop appliance

**Performance Goals**: SSH login and remote administration available after normal boot without delaying the desktop unnecessarily

**Constraints**: Boot unattended without a keyboard or monitor, preserve local recovery when peripherals are connected, retain Wi-Fi fallback while Ethernet is primary, avoid committing secrets, use idempotent commands, and require reboot validation before later appliance customization

**Scale/Scope**: One physical host, one administrator account, one normal desktop user/session, and one documented DHCP reservation/hostname

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- PASS: Work is isolated on the non-`main` feature branch.
- PASS: SSH, desktop recovery, and Wi-Fi fallback are explicit acceptance requirements.
- PASS: No credentials, private keys, cookies, or tokens are stored in the repository.
- PASS: Hardware and OS facts are captured from the live host rather than inferred from the auction listing.
- PASS: Ubuntu 26.04.1 LTS is the approved project baseline and matches the observed host.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
No application source tree. Host setup remains documented in this feature and
can later be represented by idempotent scripts under a separately scoped task.
```

**Structure Decision**: This feature produces repository documentation only. Host configuration is performed through documented, idempotent commands and later implementation tasks; no application source tree or API contracts are introduced.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | No constitution violations remain after adopting Ubuntu 26.04 LTS. | No complexity exception is required. |
