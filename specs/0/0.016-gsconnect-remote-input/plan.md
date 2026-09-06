# Implementation Plan: Phone-Based Remote Input (GSConnect)

**Spec**: `spec.md` in this directory
**Branch**: `feature/0.016-gsconnect-remote-input`
**Status**: In progress

## Approach

Install Ubuntu's `gnome-shell-extension-gsconnect`, enable it, pair the owner's Android phone through an explicit confirmation, reduce the enabled plugins to only what remote input needs, then validate typing in both Firefox and a Chromium-based browser.

The ordering matters for one reason: **plugin reduction must happen before the phone is used for anything real.** GSConnect enables a broad default plugin set on pairing, several plugins of which move data between the phone and the appliance. Pairing first and pruning later means a window in which clipboard contents, notifications, and files sync to a machine that lives in a living room. Pruning first is the difference between a text-entry tool and an unplanned phone-sync appliance.

## Environment facts captured 2026-09-05

Recorded here rather than assumed, because the specification requires it:

- **GNOME Shell 50.1.** The package declares `gnome-shell (>= 46~), gnome-shell (<< 51~)`, so 50.1 is supported — but only just. A future GNOME 51 upgrade will make this package uninstallable, which is a real maintenance consideration for an appliance meant to last.
- **`gnome-shell-extension-gsconnect` `71-1ubuntu1`** from `resolute/universe`. Not installed. No third-party source is needed.
- **No host firewall.** `ufw` reports `Status: inactive` and all iptables policies are `ACCEPT`. The specification's firewall criterion is therefore satisfied by recording this fact; no ports need opening. If a firewall is ever enabled, GSConnect needs TCP and UDP `1716-1764`.
- **Nothing is listening on `1714-1719`**, so there is no conflict with an existing KDE Connect installation.
- Appliance at `192.168.1.204` on `enp3s0`. Phone must join the same LAN.
- `gnome-shell-extension-gsconnect-browsers` exists but is **not** installed: it is browser integration for sharing links, which is out of scope.

## Plugin policy

Only what remote input requires. Every plugin capable of moving data between the phone and the appliance is disabled unless the owner asks for it, with the rationale recorded:

| Plugin | State | Rationale |
| --- | --- | --- |
| `mousepad` | **enabled** | This is the feature. Remote pointer and keyboard input. |
| `clipboard` | disabled | Would sync clipboard both ways. A living-room machine should not receive the phone's clipboard, and streaming passwords typed on the appliance should not leave it. |
| `share` | disabled | Inbound file transfer to the appliance. Out of scope. |
| `sms`, `telephony`, `notification` | disabled | Mirrors personal messages onto a television. Out of scope and privacy-adverse. |
| `sftp` | disabled | Exposes phone storage as a mount. Out of scope. |
| `runcommand` | disabled | Lets the phone execute commands on the appliance. Deliberately off; the attack surface is not worth the convenience. |
| `mpris`, `systemvolume` | disabled by default | Media control is the DualSense's job. Revisit only if the owner asks. |
| `battery`, `ping`, `findmyphone` | disabled | Not needed for input. |

## Security posture

- Pairing is an explicit, owner-confirmed exchange. No device is trusted implicitly.
- GSConnect stores its certificate, private key, and paired-device metadata under `~/.config/gsconnect/`. **Nothing from there is tracked.** The installer must not copy any of it into the repository, and the removal path must delete it.
- The appliance has no firewall, so GSConnect's listening port is reachable by anything on the LAN. This is acceptable only because pairing requires confirmation on both ends; it is recorded as a known exposure rather than glossed over.

## Sequencing

1. Install the package with an idempotent tracked script; do not enable anything yet.
2. Enable the extension. On Wayland the GNOME Shell cannot be restarted in place, so this needs a log out and back in, or a reboot. Plan for it rather than being surprised by it.
3. Apply the plugin policy **before** pairing.
4. Pair the phone with owner confirmation.
5. Validate pointer and typing from the couch, in Firefox and in a Chromium-based browser.
6. Complete the Spec 009 login and persistence acceptance that stalled on text entry.
7. Validate reboot persistence and the documented removal path.

## Risks

- **GNOME 51 will drop this package** (`<< 51~`). Recorded as a maintenance risk for Spec 013.
- **The DualSense is currently unreachable** (flat battery suspected, being charged). Pairing and validation need *some* input device; a keyboard and mouse may be required temporarily for the pairing step itself, which is acceptable because pairing is a one-time administrative action rather than routine couch use.
- Enabling the extension needs a session restart, which will interrupt anything running on the appliance.
- GSConnect's discovery relies on UDP broadcast; some networks with client isolation block it. If the phone does not appear, that is the first thing to check.

## Out of scope

As stated in `spec.md`: file transfer, clipboard sync, notification mirroring, SMS, media control; using the phone as the routine navigation device; and any change to browser choice.
