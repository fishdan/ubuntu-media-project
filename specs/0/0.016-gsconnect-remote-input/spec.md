# Feature Specification: Phone-Based Remote Input (GSConnect)

**Status**: Planned

Provide keyboard and pointer input from the owner's phone using GSConnect, the GNOME Shell implementation of the KDE Connect protocol, packaged by Ubuntu as `gnome-shell-extension-gsconnect` (`71-1ubuntu1`). This resolves the text-entry problem that Spec 009 investigated and could not solve.

Spec 009 established through a captured Wayland protocol trace that GNOME's on-screen keyboard depends on the focused application cooperating with the compositor's text-input protocol, and that Brave/Chromium does not get GNOME to show the keyboard even when its client-side handshake looks correct. Remote input sidesteps that entire class of problem: GSConnect injects pointer and key events at the input layer, the same way a physical keyboard does, so it works regardless of whether the focused application supports the on-screen-keyboard trigger. This also means browser choice stops being constrained by keyboard support.

## Relationship to Existing Specifications

- **Depends on Spec 015**: The desktop-first home is the surface being driven. This feature is validated against that layout.
- **Largely supersedes Spec 010**: Pointer control is already provided by the Spec 008 DualSense mapping, and text entry is provided here. Spec 010 is reduced to whatever neither covers.
- **Unblocks Spec 009 acceptance**: Login and account-persistence testing that stalled on text entry can complete.

## Prerequisites and Open Questions

- **Phone platform must be confirmed before implementation.** The KDE Connect Android client provides remote keyboard and touchpad input. The iOS client has historically offered a reduced feature set, and remote input may be unavailable. If the owner's phone is an iPhone, this approach must be validated early or replaced with an alternative before further work.
- Phone and appliance must be on the same trusted LAN, with the appliance reachable at its existing address.

## Acceptance Criteria

- `gnome-shell-extension-gsconnect` is installed from the Ubuntu repository through an idempotent, tracked script. No third-party package source is added.
- The owner's phone is paired through an explicit, owner-confirmed pairing exchange. Pairing is not automatic and no device is trusted implicitly.
- Pairing certificates, device keys, device identifiers, and any paired-device metadata remain outside version control.
- Only the plugins required for this feature are enabled. Plugins that are not needed for remote input are disabled and the enabled set is documented, with a stated rationale for anything that can move data between the phone and the appliance.
- The owner can move the pointer, click, and type into a browser text field from the phone, from the couch, without a physical keyboard or mouse.
- Remote typing is verified to work in a Chromium-based browser as well as Firefox, confirming that input works independently of the browser's on-screen-keyboard support.
- A password can be entered into a streaming-service login field and the resulting session persists across a browser close and relaunch, completing the acceptance that Spec 009 could not finish.
- If a host firewall is enabled on the appliance, the required GSConnect ports are documented and applied reproducibly; if no firewall is enabled, that fact is recorded rather than assumed.
- Pairing survives a reboot, or the reconnection procedure is documented if it does not.
- A documented removal path exists: unpairing the phone and disabling or removing the extension restores the prior state without affecting SSH, automatic login, or the desktop.
- SSH access and GNOME/TTY recovery remain intact throughout installation, pairing, and testing.

## Out of Scope

- File transfer, clipboard synchronization, notification mirroring, SMS, and media control, unless the owner explicitly requests them as a later addition with a recorded rationale.
- Using the phone as the routine navigation device. The DualSense remains the primary couch controller; the phone is for text entry and occasional pointer work.
- Any change to browser choice. That decision is revisited separately now that keyboard support no longer constrains it.
