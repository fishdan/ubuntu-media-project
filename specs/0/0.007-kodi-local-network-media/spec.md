# Feature Specification: Kodi and Local/Network Media

**Status**: Planned

Provide a fullscreen, controller-navigable Kodi home for local and network media and supported streaming add-ons. Where media lives on another Linux system, use documented and recoverable NFS/systemd automount configuration so unavailable shares do not block boot.

## Acceptance Criteria

- Kodi is installed from the Ubuntu 26.04 repository and launches through the existing `media-home.service` entry point.
- Kodi opens fullscreen and returns to the recoverable GNOME desktop when intentionally exited.
- Basic keyboard navigation and local sample-media playback work before controller-specific mapping is introduced in Spec 008.
- Network media uses NFS only after the server, export, and local mount choices are explicitly supplied and validated.
- Any persistent NFS mount uses systemd automount/no-fail behavior so an unavailable server cannot block boot or graphical login.
- Kodi userdata containing credentials, tokens, databases, thumbnails, or machine-specific state remains outside Git.
- SSH and the documented media-startup disable path remain usable throughout installation, launch, exit, and reboot tests.
- Final couch/controller acceptance is deferred to Spec 008, and receiver/projector/audio acceptance remains deferred to Spec 005.
