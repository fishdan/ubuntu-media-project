# Research: Automatic Login and Appliance Startup

## Decision: Preserve the existing GDM automatic login and make it reproducible

The host already has `AutomaticLoginEnable=true` and `AutomaticLogin=dfish`. The implementation should validate and reconcile those keys idempotently rather than replacing the whole GDM configuration or changing display-manager service ownership.

## Decision: Use a systemd user service for the media entry point

A user service provides status, logs, explicit enable/disable commands, dependency ordering, and a stable integration point for Kodi. It is more observable and recoverable than shell-profile startup.

## Decision: Do not restart the media home automatically yet

An unconditional `Restart=always` policy can trap the desktop in a crash loop or relaunch after an intentional exit. The initial unit has no restart policy. Supervision can be added only after Kodi exit semantics and return-home behavior are specified.

## Decision: Treat missing Kodi as a safe staged state

Spec 006 precedes Spec 007. The launcher will report that Kodi is unavailable and exit successfully to the GNOME desktop. Spec 007 can install Kodi and validate the same launch path without changing login orchestration.

## Decision: Separate login recovery from media-startup recovery

Administrators must be able to disable `media-home.service` while keeping automatic login, or disable GDM automatic login while retaining SSH and local login. Recovery commands and deployed-file locations are documented separately.
