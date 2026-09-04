# Data Model: Kodi and Media Sources

This feature has no application database managed by the repository.

## Kodi Installation

- Package source and version
- Executable availability
- Startup service state and journal result
- Fullscreen, navigation, playback, and exit observations

## Local Media Test

- Reviewed local path
- Non-sensitive test filename/type
- Video and audio playback observations
- Rendering limitations attributable to the temporary monitor/audio setup

## Network Media Source

- NFS server hostname or address supplied by the owner
- Export path
- Local mount path
- Read-only/read-write intent
- Mount and automount unit names derived from the local path
- Timeout and boot-failure behavior

## Runtime Data Boundary

- `~/.kodi` is machine/runtime state and remains untracked
- Credentials and tokens are never accepted as script arguments that would leak into process listings or Git
- Kodi databases, thumbnails, caches, logs, and watched-state files remain outside the repository

## Validation

Kodi must remain recoverable through SSH and GNOME. An unavailable NFS server must not block boot. Detected or visually tested monitor behavior must not be described as receiver/projector acceptance.
