# Implementation Plan: Desktop-First Home and Kodi Retirement

**Spec**: `spec.md` in this directory
**Branch**: `feature/0.015-desktop-first-home`
**Status**: In progress

## Approach

This change is subtractive. Kodi already runs as a fullscreen window inside the ordinary GNOME Wayland session, so the desktop is already underneath everything the appliance does. The work is to stop launching Kodi automatically, delete the stop/restore orchestration that existed only to serve it, and make the desktop legible from the couch.

Nothing is uninstalled and nothing is deleted from the repository. Every retired mechanism stays present but inert, so the revert path is a single `systemctl --user enable --now media-home.service` plus one settings rollback command. This is what keeps a change to automatic startup within the constitution's requirement for a documented escape path.

## Sequencing and rationale

The order below is chosen so the appliance is never left in a state where both the old and new homes are half-configured.

1. **Retire the automatic Kodi launch first.** Disabling `media-home.service` is the single change that defines the feature, and it is instantly reversible. Doing it first means every later step is validated against the real target state.
2. **Then simplify the Zuzz launcher.** `launch-zuzz.sh` currently stops Kodi on start and restarts it on stop. Once nothing launches Kodi, that orchestration is not merely unnecessary — it is actively harmful, because it re-enables the very service the feature just retired. This step must not happen before step 1, or the launcher would restore Kodi on every browser exit.
3. **Then make the desktop couch-legible.** Only meaningful once the desktop is what actually appears at boot.
4. **Then roadmap bookkeeping**, which records the consequences of steps 1-3 across the affected specifications.
5. **Then validation and owner acceptance**, including a reboot, because the feature's central claim is about boot behavior.

## Known defect this feature resolves

Recorded 2026-09-05: stopping `media-home.service` leaves it in `failed` state, because Kodi's main process exits on SIGTERM but the `kodi.bin` child survives to the unit's `final-sigterm` timeout and is SIGKILLed. This feature removes every code path that stops the unit, so the defect stops being reachable rather than being papered over. No attempt is made to fix Kodi's shutdown behavior.

## Files affected

| File | Change |
| --- | --- |
| `scripts/install-media-startup.sh` | Install the unit and launcher but no longer `enable --now` it; print the revert command. Keeps Spec 006 reproducible in both directions. |
| `scripts/launch-zuzz.sh` | Remove the `media-home.service` stop from `--run` and the start from `--restore`. `--restore` keeps only the DualSense mode reset. |
| `scripts/configure-desktop-home.sh` | New. Idempotent `--apply` / `--revert` for projector-distance display settings and curated launchers, capturing prior values before writing. |
| `config/applications/zuzz.desktop` | Retained as-is; it is the desktop launcher the new home depends on. |
| `config/systemd/user/media-home.service` | Retained unchanged and untracked-for-enablement, purely as the revert path. |
| `docs/desktop-home.md` | New. The couch-facing home, the settings applied, and the full revert procedure. |
| `README.md`, `setup.md` | Roadmap and description updated from Kodi-first to desktop-first. |
| `specs/0/0.007-*`, `0.010-*`, `0.011-*`, `0.012-*` | Status bookkeeping per the specification's Acceptance Criteria. |

## Settings baseline captured for rollback

Read from the live appliance on 2026-09-05 before any change:

- `org.gnome.desktop.interface text-scaling-factor` = `1.0`
- `org.gnome.desktop.interface cursor-size` = `24`
- `org.gnome.desktop.interface font-name` = `'Adwaita Sans 11'`
- `org.gnome.shell favorite-apps` = `['firefox_firefox.desktop', 'org.gnome.Nautilus.desktop', 'snap-store_snap-store.desktop', 'org.gnome.Yelp.desktop', 'org.gnome.Ptyxis.desktop', 'brave-browser.desktop']`

`configure-desktop-home.sh --revert` restores exactly these values. They are recorded here as well as in the script so the rollback survives the script being edited.

## Risks

- **GNOME is not a ten-foot interface.** Display scaling and large text reduce but do not eliminate this. If the owner finds the desktop unusable at projector distance, the fallback is not to re-enable Kodi but to reconsider the launcher presentation; Kodi's retirement rests on the absence of a local media library, which scaling does not change.
- **Text entry is not solved here and is not claimed to be.** It remains a dependency on Spec 016, which is itself blocked on the owner's phone platform.
- **Automatic login and SSH must not regress.** Both are validated explicitly after the reboot rather than assumed, because this feature touches the session's startup path.

## Out of scope

As stated in `spec.md`: text entry and phone-based input, Steam installation, removal of the Kodi package or its userdata, and any change to GDM automatic login, SSH, or the Spec 003/006 recovery paths.
