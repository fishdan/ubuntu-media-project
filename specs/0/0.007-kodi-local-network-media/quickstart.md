# Quickstart: Kodi and Local/Network Media

Run from the repository root on `orpheus` with SSH connected and the temporary monitor visible.

## 1. Baseline

```bash
systemctl is-active ssh
systemctl --user is-enabled media-home.service
command -v kodi || true
apt-cache policy kodi nfs-common
```

## 2. Install Kodi

```bash
sudo scripts/install-kodi.sh
command -v kodi
kodi --version
```

Restart the existing entry point:

```bash
systemctl --user restart media-home.service
journalctl --user -u media-home.service -b --no-pager
```

Observe fullscreen launch on the attached monitor. Validate keyboard navigation, play a known local media sample, and intentionally exit to GNOME. Disable startup for recovery with `systemctl --user disable --now media-home.service`.

## 3. Configure network media only when inputs are known

Do not guess the server or export. Review the proposed inputs first, then use the NFS configuration script documented in `docs/network-media.md`. Never place a password in the command line or repository; NFS authentication assumptions must be documented separately.

## 4. NFS failure and reboot tests

With an approved NFS source configured, prove that its automount works on access. Then make the server temporarily unavailable and confirm boot, SSH, graphical login, and Kodi still complete without waiting indefinitely.

## Acceptance

Spec 007 completes when Kodi launches through `media-home.service`, local playback and intentional exit pass, any requested NFS source is recoverable and non-blocking, reboot succeeds, and the repository secret/runtime-data scan passes. If no NFS source is requested, record that explicit scope decision rather than inventing one.
