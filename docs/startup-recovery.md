# Automatic Login and Media Startup Recovery

## Managed state

- GDM automatically logs in the existing non-root user `dfish`.
- `media-home.service` starts from the GNOME graphical-session target.
- The service invokes `~/.local/bin/launch-media-home`, deployed from the repository.
- There is no automatic restart policy. An intentional exit or failure cannot create a relaunch loop.
- Before Spec 007 installs Kodi, the launcher logs a staged-state message and leaves GNOME usable.

## Inspect

```bash
systemctl is-active ssh
sudo scripts/configure-autologin.sh --check dfish
systemctl --user status media-home.service
journalctl --user -u media-home.service -b --no-pager
```

## Disable media startup only

From SSH or a terminal in GNOME:

```bash
systemctl --user disable --now media-home.service
```

Automatic GNOME login remains enabled. Restore media startup with:

```bash
systemctl --user enable --now media-home.service
```

## Disable automatic login only

```bash
sudo scripts/configure-autologin.sh --disable
```

This preserves SSH, GDM, and normal local login. Restore automatic login with:

```bash
sudo scripts/configure-autologin.sh --apply dfish
```

The first changed configuration creates `/etc/gdm3/custom.conf.before-media-appliance`. For exact recovery, inspect that file locally and restore it only when necessary.

The disable/restore drill was completed on 2026-09-04. SSH remained active while automatic login was disabled, and the intended `AutomaticLoginEnable=true` / `AutomaticLogin=dfish` state was restored before reboot.

## Local recovery

- Use the attached monitor and normal GNOME desktop if the media home does not start.
- Press `Ctrl`+`Alt`+`F3` for a text console, log in, and disable the user service.
- SSH remains independent of GDM and the user service.
- Do not disable `display-manager.service` to troubleshoot the media launcher.

The media-service disable/restore drill was also completed on 2026-09-04. Disabling the unit left SSH and GNOME intact, and reinstalling/enabling it restored the graphical-session target link.
