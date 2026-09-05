# Research: Kodi and Local/Network Media

## Decision: Use Ubuntu's Kodi package

Ubuntu 26.04 currently offers Kodi `2:21.3+dfsg-1ubuntu1` from the `universe` repository. It integrates with the distribution package lifecycle and avoids adding an unnecessary third-party package source.

## Decision: Reuse the Spec 006 media-home launcher

`media-home.service` already provides the controlled graphical-session entry point, recovery controls, and no-restart-loop behavior. Installing Kodi should make that existing path functional rather than adding a second autostart mechanism.

## Decision: Keep Kodi userdata untracked

The Kodi profile can contain media databases, thumbnails, watched state, network paths, usernames, passwords, tokens, and add-on state. Repository configuration will be limited to reviewed, non-secret automation and documentation.

## Decision: Validate local playback before network media

Local playback separates Kodi/rendering behavior from NFS availability and permissions. A small known media file can establish the basic path before adding a remote dependency.

## Decision: Use systemd automount for NFS

An `.automount` unit defers the network connection until the media path is accessed. The paired `.mount` unit will include `_netdev`, `nofail`, and bounded timeout behavior. Exact server/export/mount inputs remain pending human direction.

## Decision: Defer controller and permanent AV acceptance

Keyboard/fullscreen behavior on the attached monitor is sufficient for this feature's installation validation. DualSense navigation belongs to Spec 008; receiver/projector modes and HDMI audio belong to the paused Spec 005.
