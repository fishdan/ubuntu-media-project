# Implementation Plan: Steam Big Picture

**Spec**: `spec.md` in this directory
**Branch**: `feature/0.011-steam-big-picture`
**Status**: In progress

## Approach

Install Steam from Ubuntu's `multiverse`, launch it into Big Picture from a tracked desktop entry, make the DualSense hand-off automatic, and extend `return-home.sh` so the PS button can close it.

Two pieces are real work. Everything else is installation and acceptance.

## The two hard parts

### 1. The controller hand-off must be automatic

Spec 008 recorded that input-remapper's media mode has to be **off** before Steam launches, or Steam Input sees remapped keyboard and mouse events rather than a gamepad. Spec 015 then made that mode **on by default at login**, because the desktop needs a pointer.

Those two facts collide. Steam now always launches into exactly the wrong controller state.

Telling the owner to run `dualsense-media-mode.sh off` from the couch before starting Steam is not a solution — it needs a keyboard, which is the thing this appliance is built to avoid. So the launcher must turn media mode off on start and back on when Steam exits, the same shape as the Kodi orchestration Spec 015 deleted.

That is worth calling out honestly: this feature reintroduces a small amount of the stop/restore orchestration that Spec 015 removed. The difference is scope. Spec 015 deleted orchestration between two *sessions* competing for the screen; this is a single launcher toggling one input mode it owns, with the desktop still underneath the whole time. It is bounded and reversible, and there is no alternative that keeps the appliance keyboard-free.

### 2. `return-home.sh` must handle transient scopes

`return-home.sh` currently stops a fixed list of systemd *units*. Steam launched from a desktop entry is not a unit — GNOME starts it in a transient `app-gnome-steam-NNNN.scope` under `app.slice`. The PS button would stop nothing and leave Steam on screen, silently regressing an accepted Spec 015 criterion.

The rework: keep stopping known units first, then stop matching transient app scopes. This must not regress `zuzz-media.service`, which is a real unit and must still be stopped the existing way. Spec 017 will need the same capability for dock-launched Brave, so the mechanism should be general rather than Steam-specific.

## Sequencing

1. Enable `i386` and install `steam-installer`, idempotently and tracked.
2. Complete Steam's own first-run bootstrap, which downloads Valve's client.
3. Rework `return-home.sh` for transient scopes, and verify the browser path still works **before** relying on it for Steam.
4. Add the Steam launcher with the automatic media-mode hand-off, plus a desktop entry, and put Steam in the dock.
5. Owner acceptance from the couch: Big Picture, Steam Input, a test game, and the PS button.
6. Removal path, documentation, and the pre-PR checks.

## Honest notes on what this appliance can play

The GPU is a **GTX 1060 with 3 GB of VRAM**. That is a capable 1080p card for older and lighter titles and a poor match for anything modern at projector resolution. 3 GB of VRAM, not raw shader performance, will be the first thing to run out.

The session is Wayland, so Steam runs through XWayland; Big Picture is generally fine there but it is an extra layer, and it is where to look first if input or fullscreen behaves oddly.

Acceptance will state what the test title actually does. A title that stutters will be recorded as stuttering.

## Security note to record, not gloss

`steam-installer` is a **bootstrap**. The Ubuntu package installs a launcher and 32-bit libraries; the Steam client itself is then downloaded from Valve and self-updates outside APT. So "installed from the Ubuntu repository" is true of the package and not of the software that ends up running.

Enabling `i386` also widens the installed surface with a parallel 32-bit library stack. Both facts belong in the docs so a future maintainer is not misled by the tracked installer looking tidy.

## Risks

- The controller hand-off has an obvious failure mode: if Steam exits abnormally, media mode could stay off and leave the desktop without a pointer. The launcher must restore it even on abnormal exit, and the PS button path must not depend on media mode being on.
- Steam's first run is interactive — login, possibly a Steam Guard code. That needs the phone-based text entry from Spec 016, which is exactly the sort of thing it was built for.
- A 3 GB card may simply not run whatever title the owner wants to test. That is a hardware fact, not a defect to fix.

## Out of scope

As stated in `spec.md`: a large game library, Proton or anti-cheat troubleshooting, Steam Link and remote play, GPU tuning, and Steam Input profile design.
