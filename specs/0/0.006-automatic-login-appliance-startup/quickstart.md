# Quickstart: Automatic Login and Appliance Startup

Run from the repository root on `orpheus`. Keep the attached monitor available and confirm SSH before rebooting.

## 1. Inspect

```bash
systemctl is-active ssh
systemctl status display-manager.service
sudo scripts/configure-autologin.sh --check dfish
systemctl --user status media-home.service
```

## 2. Reconcile automatic login

```bash
sudo scripts/configure-autologin.sh --apply dfish
sudo scripts/configure-autologin.sh --check dfish
```

The script updates only the GDM daemon keys it owns and keeps a recoverable backup. It must reject root and nonexistent users.

## 3. Install the user startup service

```bash
scripts/install-media-startup.sh
systemctl --user status media-home.service
journalctl --user -u media-home.service --no-pager
```

Before Kodi is installed, the service should log a clear staged-state message and leave the GNOME desktop usable.

## 4. Recovery

Disable only media startup:

```bash
systemctl --user disable --now media-home.service
```

Restore it:

```bash
systemctl --user enable media-home.service
```

Disable automatic login while preserving SSH and normal GDM login:

```bash
sudo scripts/configure-autologin.sh --disable
```

Use the backup path printed by the configuration script for exact file restoration if required.

## 5. Reboot acceptance

Confirm SSH is active, reboot, observe automatic GNOME login on the attached monitor, reconnect over SSH, verify the active graphical seat, and inspect the user-service journal. Confirm a local TTY remains accessible.

## Acceptance

Spec 006 completes when the configuration is reproducible, automatic GNOME login and SSH survive reboot, the media startup service fails safely while Kodi is absent, and both disable/recovery paths are demonstrated.
