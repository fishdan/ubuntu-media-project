# Kodi Setup and Recovery

## Scope

Spec 007 installs Kodi from Ubuntu's repository and integrates it with the existing `media-home.service`. NFS is explicitly out of scope by owner decision. Kodi can use local media now; a separate feature can add network media later if it becomes necessary.

Controller behavior is deferred to Spec 008. Receiver/projector modes and HDMI audio remain in postponed Spec 005.

## Installation

```bash
sudo scripts/install-kodi.sh
```

The script is idempotent and installs the Ubuntu `kodi` package plus the Ubuntu-packaged `kodi-send` event client for SSH recovery and validation. It does not add a third-party package repository.

## Startup

Kodi uses the existing Spec 006 path:

```text
GNOME graphical session
  → media-home.service
  → ~/.local/bin/launch-media-home
  → kodi -fs
```

Kodi runs fullscreen inside the recoverable GNOME session. `--standalone` is intentionally not used because that mode assumes Kodi is operating without a normal window manager.

GNOME idle blanking is disabled for the media session so an unattended monitor does not sleep during validation or media use:

```bash
scripts/configure-kodi-session.sh --apply
```

Restore the Ubuntu default with `scripts/configure-kodi-session.sh --restore-default`.

Restart it from SSH with:

```bash
systemctl --user restart media-home.service
```

Send a local Kodi action from SSH with:

```bash
kodi-send --host=127.0.0.1 --action='ACTION_NAME'
```

This uses Kodi's local event interface and does not expose a web password or commit runtime configuration.

## Recovery and intentional exit

Disable automatic media startup without disabling GNOME automatic login:

```bash
systemctl --user disable --now media-home.service
```

Restore it with:

```bash
systemctl --user enable --now media-home.service
```

An intentional Kodi exit returns to the GNOME desktop because the unit has no restart policy.

If Kodi's own Quit action hangs during shutdown, use the bounded service recovery path:

```bash
systemctl --user stop media-home.service
```

The unit allows ten seconds for clean shutdown, then terminates the remaining service processes so the GNOME desktop is recoverable. Testing found that Kodi can hang after its event server stops when the HDMI audio sink disappears; the bounded service stop reliably returned the attached monitor to GNOME in that case.

## Runtime-data boundary

Kodi stores its runtime profile under `~/.kodi`. That directory can contain databases, thumbnails, logs, watched state, add-ons, network paths, credentials, and tokens. It must remain outside this repository.

## Validation status

- Installed version: `2:21.3+dfsg-1ubuntu1` from Ubuntu `resolute/universe`
- Executable: `/usr/bin/kodi`
- Startup: active through `media-home.service` with `kodi --standalone`
- Display: Kodi is visibly running fullscreen on the attached HP monitor
- Audio routing: waking the monitor exposed the NVIDIA HDMI sink, and PipeWire shows the Kodi stream routed to `HP 2310`; audible playback is not yet confirmed
- Navigation: local `kodi-send` actions visibly moved the interface without requiring a keyboard on the appliance
- Local playback: the selected GNOME WebM test clip visibly played fullscreen using Kodi's VP8 decoder
- Intentional exit: `kodi-send Quit` exits normally when the HDMI sink remains healthy; with a failed/disappeared sink it may hang and requires the bounded service stop
- Recovery: the bounded stop returned the monitor to GNOME in both observed stuck-shutdown cases
- Installed-Kodi recovery: disabling and restoring `media-home.service` preserved SSH and GNOME and restored automatic media startup
- Reboot: SSH, automatic GNOME login, disabled idle blanking, and automatic fullscreen Kodi startup all returned successfully
- Final watched cycle: normal Quit returned to GNOME with a successful service result, and a subsequent service start visibly restored fullscreen Kodi

The system-provided `/usr/share/help/C/gnome-help/figures/display-dual-monitors.webm` file is the selected non-copyrighted local video test asset. It is outside the repository and need not be copied into Git.
