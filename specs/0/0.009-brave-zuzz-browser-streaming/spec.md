# Feature Specification: Zuzz Browser Streaming

**Status**: In progress

Launch https://zuzz.tv in Firefox with a dedicated media profile outside Git, fullscreen app-style presentation, controller primitives, and a managed exit back to Kodi.

Originally implemented with the already-installed Brave browser. Brave was replaced with the already-installed Firefox after owner acceptance testing showed GNOME's on-screen keyboard never appears for Brave/Chromium web-content text fields (confirmed via a captured Wayland protocol trace showing Brave's client behavior, despite being protocol-correct, does not get GNOME Shell to show the keyboard) while it works correctly and immediately in Firefox on the same page. See `progress.ai` entries dated 2026-09-04 for the diagnostic trail.

## Acceptance criteria

- Verify the installed Firefox executable/version; preserve the existing personal browser profile.
- Use a private media profile outside Git; credentials and browser runtime data never enter tracked artifacts.
- A repeatable user-service/desktop launcher opens Zuzz; repeated launch requests do not create competing managed instances.
- Stop Kodi before browsing; normal browser exit, failed startup, or an administrator stop restores Kodi and attempts to disable media remapping. Remapping cleanup failures remain visible.
- Validate projector presentation, receiver audio, owner-operated login, actual streaming playback, browser back/pointer/click, and close/relaunch session persistence.
- On-screen-keyboard text entry in website fields must work without a physical keyboard; this is satisfied by Firefox and was the reason Brave was replaced.
- Preserve SSH and GNOME recovery. No sandbox disabling, remote-debugging port, or global browser security changes.
- Universal controller return-home and Kodi home-menu integration are Spec 012; Steam is Spec 011. This feature supplies a stable launch/stop interface for later integration.
