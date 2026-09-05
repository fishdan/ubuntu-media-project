# Data Model: Appliance Startup State

This feature has no application database. It manages these operational states.

## Display Manager Login

- GDM service/alias and active state
- Automatic-login enabled flag
- Automatic-login user
- Normal graphical and TTY login recovery

## Media Startup

- Installed launcher path and checksum/source
- Installed systemd user unit
- Enabled/disabled state
- Last activation result and journal evidence
- Runtime dependency state (`kodi` present or absent)

## Recovery Controls

- Disable media startup independently
- Stop the current media service
- Restore or disable automatic login
- Reconnect through SSH and use a local TTY

## Validation

The configured user must exist and must not be root. Scripts must be idempotent. Missing Kodi must preserve a usable GNOME desktop. Reboot validation must prove SSH and local graphical recovery.
