# Feature Specification: Desktop-First Home and Kodi Retirement

**Status**: In progress

Replace the Kodi-first media home with the ordinary GNOME desktop as the appliance's home experience. The project owner has confirmed there will never be a local media library, which removes Kodi's primary value and leaves it acting only as a launcher shell. Booting to the desktop and launching streaming or gaming applications directly deletes the session stop/restore orchestration that has been the most failure-prone part of the appliance.

This change is mostly subtractive and therefore low risk: Kodi already runs as a fullscreen window inside the normal GNOME Wayland session rather than as a standalone session, so the GNOME desktop is already underneath everything. The work is to stop launching Kodi automatically, present a couch-legible desktop, and remove the orchestration that existed only to restore Kodi.

## Relationship to Existing Specifications

- **Amends Spec 006**: GDM automatic login and the reproducible startup configuration remain required and unchanged. Only the Kodi-launching half of `media-home.service` retires.
- **Supersedes Spec 007**: Kodi as the media home is retired. NFS and local/network media remain out of scope and are not reintroduced.
- **Supersedes most of Spec 012**: With no session to restore, a universal return-home mechanism is unnecessary; "home" becomes closing the active application.
- **Reduces Spec 010**: Pointer control is already satisfied by the Spec 008 DualSense mapping. Text entry is explicitly deferred to the GSConnect feature and is not solved here.
- **Simplifies Spec 011**: Steam Big Picture launches from the desktop and exits to the desktop, with no Kodi restoration path.

## Acceptance Criteria

- After a normal boot with automatic login, the appliance reaches the GNOME desktop and starts no media application automatically; `media-home.service` is disabled and does not launch Kodi.
- Kodi remains installed and launchable as an ordinary desktop application. It is not removed, so the decision stays reversible and no reinstallation is required to revert.
- The Zuzz launcher no longer stops or restores Kodi. `scripts/launch-zuzz.sh --restore` only disables controller remapping, and `zuzz-media.service` is retained solely as the administrator's SSH-side stop path.
- The desktop presents a curated, couch-legible set of launchers for the streaming browser and future Steam entry. Display scaling and large-text settings suitable for projector viewing distance are applied through recorded, reproducible `gsettings` commands with their prior values captured for rollback.
- The Spec 008 DualSense pointer mode can navigate the desktop, launch the streaming browser, and return to the desktop by closing it, without a keyboard or mouse.
- A documented revert path exists: re-enabling `media-home.service` restores Kodi-first startup without reinstalling or reconfiguring anything.
- SSH access, GNOME desktop recovery, local TTY recovery, and Spec 006 automatic login remain intact throughout the change and after a reboot.
- Roadmap bookkeeping is completed: Spec 007 is marked superseded, Spec 012 is retired or reduced to its remaining value, and Spec 010 is reduced to whatever the GSConnect feature does not cover.
- Text entry without a physical keyboard remains a known open dependency handled by the next feature. This specification does not claim to solve it.
- No local media library, NFS export, or network mount is assumed, configured, or reintroduced.

## Out of Scope

- Text entry, on-screen keyboards, and phone-based remote input (next feature).
- Steam installation and Big Picture validation (Spec 011).
- Removing the Kodi package or deleting Kodi userdata.
- Any change to GDM automatic login, SSH, or the recovery paths established in Specs 003 and 006.
