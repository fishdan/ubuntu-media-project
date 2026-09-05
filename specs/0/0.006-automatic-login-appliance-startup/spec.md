# Feature Specification: Automatic Login and Appliance Startup

**Status**: Complete (amended by Spec 015)

> **Amended by Spec 015 on 2026-09-05.** GDM automatic login and the reproducible startup
> configuration remain required and unchanged. Only the Kodi-launching half of
> `media-home.service` retired; the unit and its launcher stay installed, disabled, as the
> documented revert path.

After remote recovery is proven, configure GNOME automatic login and a deliberate user-session startup mechanism for the media home. Use maintainable systemd user services or GNOME autostart entries, prevent restart loops, and document how to temporarily disable or recover the startup behavior.

## Acceptance Criteria

- GDM automatically starts the dedicated `dfish` GNOME session after a normal boot without requiring keyboard input.
- The automatic-login configuration is reproducible and idempotent without weakening SSH authentication.
- A systemd user service provides one controlled media-home startup point and does not create a crash/restart loop.
- Until Kodi is delivered by Spec 007, the startup point exits safely to the normal GNOME desktop and reports the missing dependency clearly.
- Installing Kodi later activates the same startup path without redesigning login orchestration.
- An administrator can disable media startup remotely without disabling GNOME automatic login, and can disable automatic login separately when needed.
- SSH and local graphical/TTY recovery remain available after reboot.
