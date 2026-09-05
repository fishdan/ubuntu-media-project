# Feature Specification: Graphics, AV Display, HDMI Audio, and Power

**Status**: Complete with owner-approved AV-off boot test waiver (2026-09-04).

Configure the verified display hardware for projector output through the AV receiver, including correct resolution/refresh, HDMI audio, no unwanted blanking or suspend during use, and predictable recovery from receiver/projector power or hot-plug changes. Validate boots with the AV equipment on and off.

## Acceptance Criteria

- The NVIDIA GPU drives the AV receiver/projector through HDMI at the projector's native resolution and an appropriate refresh rate.
- Audio plays through the receiver over the NVIDIA HDMI path and remains selected after reboot.
- Automatic suspend is disabled while plugged in, and screen blanking does not interrupt normal media use.
- SSH and the normal GNOME desktop remain available throughout configuration and recovery.
- The graphical session recovers after receiver/projector power cycling and HDMI hot-plug events without requiring a reinstall or destructive reset.
- Boots with AV equipment powered on and powered off are both tested and documented.
- Every persistent change has a documented rollback or recovery command.

## Owner-approved acceptance scope

On September 4, 2026, the owner explicitly requested skipping the remaining AV-off boot scenario and creating the PR. AV-on boot passed. AV-off boot followed by later AV power-on remains untested, not passed. Recovery durations were not measured.
