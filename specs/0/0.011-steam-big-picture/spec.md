# Feature Specification: Steam Big Picture

**Status**: In progress

> **Simplified by Spec 015 on 2026-09-05.** Steam launches from the GNOME desktop and exits back
> to it. There is no Kodi restoration path to build or validate, and the "return to media home"
> requirement reduces to closing the application.

Launch Steam from the desktop directly into Big Picture, verify the DualSense through Steam Input, validate a test game, and return to the desktop on exit. Actual game capability must reflect the detected GPU, not aspiration.

## Environment facts captured 2026-09-06

Recorded before planning, so the specification reflects the real machine:

- **Steam is not installed.** `steam-installer` `1:1.0.0.85~ds-2build1` is available from Ubuntu `resolute/multiverse`, which is already enabled. No third-party APT source is needed.
- **32-bit multiarch is not enabled.** `dpkg --print-foreign-architectures` is empty, and `steam-installer` depends on `steam-libs-i386`. Enabling `i386` is a prerequisite and a system-wide change.
- **GPU is a GeForce GTX 1060 with 3 GB VRAM**, driver `580.173.02`. 3 GB is the binding constraint on what this appliance can realistically play.
- **The session is Wayland.** Steam is an X11 application and will run through XWayland.
- Root filesystem has ~201 GB free of 233 GB, so storage is not a constraint for a modest library.

## Relationship to Existing Specifications

- **Depends on Spec 015**: Steam launches from, and exits to, the desktop-first home.
- **Depends on Spec 008**: the DualSense must reach Steam as a native controller. Spec 008 recorded the checkpoint that input-remapper's media mode has to be **off** before launching Steam, or Steam Input sees remapped keyboard and mouse events instead of a gamepad.
- **Extends Spec 015's return-home**: `scripts/return-home.sh` stops fullscreen application *units*. Steam launched from the desktop runs in a transient `app-gnome-*.scope`, not a unit, so the PS button cannot currently close it. This specification owns that rework.

## Acceptance Criteria

- Steam is installed from the Ubuntu repository through an idempotent, tracked script. No third-party APT source is added. The `i386` architecture requirement is applied reproducibly and recorded.
- It is recorded honestly that the Ubuntu package is a bootstrap: the Steam client it installs updates itself from Valve at runtime, so the software actually executing is not wholly Ubuntu-managed. The security implication is stated rather than implied.
- Steam launches from the desktop into Big Picture without a keyboard or mouse, using a tracked launcher and desktop entry.
- **DualSense media mode is turned off automatically when Steam launches, and restored when Steam exits.** Requiring the owner to remember a manual step from the couch is not acceptable.
- Steam Input sees the DualSense as a native gamepad, with no duplicate or phantom input from input-remapper.
- The PS button returns to the desktop from Steam, via a reworked `return-home.sh` that closes transient application scopes rather than only fixed units. This must not regress the existing browser behaviour.
- A test game runs, and its performance is judged against the GTX 1060 3 GB honestly. Titles beyond the GPU's capability are recorded as out of reach rather than presented as working.
- Steam credentials, tokens, library contents, and game installation paths remain outside version control.
- A documented removal path exists: uninstalling Steam and reverting the `i386` architecture without affecting SSH, automatic login, the desktop, or the DualSense.
- SSH access and GNOME/TTY recovery remain intact throughout installation and testing.

## Out of Scope

- Buying, installing, or validating a large game library. One representative test title is enough.
- Proton or anti-cheat troubleshooting for specific titles.
- Steam Link, remote play, or streaming from another machine.
- Overclocking, undervolting, or any GPU tuning.
- Replacing the DualSense mapping with Steam Input profiles outside Steam itself.
