# Research: Graphics, AV Display, HDMI Audio, and Power

## Decision: Keep the installed Ubuntu-recommended NVIDIA driver

Ubuntu reports `nvidia-driver-580` as recommended for the GTX 1060, and the installed package matches the repository candidate. Driver replacement is unnecessary unless AV testing exposes a driver-specific defect.

## Decision: Inspect DRM, GNOME, and PipeWire before changing settings

DRM connector state and EDID establish what is physically detected; GNOME/Mutter owns the Wayland display layout; PipeWire/WirePlumber owns audio routing. Evidence from all three layers is needed before persistent changes.

## Decision: Treat projector and receiver observations as mandatory evidence

Software can report a connector and sink while the image is cropped, unstable, silent, or routed incorrectly. Resolution, refresh, audio, power cycling, and boot behavior therefore require human-visible checks.

## Decision: Scope power changes to the media user and AC power

Disable automatic suspend while plugged in and select a deliberate blanking policy for the media session. Preserve manual suspend/shutdown and document original values before any change.

## Decision: Preserve remote recovery during every test

Maintain an authenticated SSH session or verified reconnection path while changing AV state. Prefer normal GNOME Settings and documented `gsettings`/PipeWire commands; avoid deleting monitor or audio configuration as a first response.
