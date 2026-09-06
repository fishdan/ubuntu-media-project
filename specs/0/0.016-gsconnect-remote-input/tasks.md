# Tasks: Phone-Based Remote Input (GSConnect)

Ordered per `plan.md`. **T004 must precede T005**: GSConnect enables a broad
default plugin set, several plugins of which move data between the phone and the
appliance. Pairing before pruning opens a window in which clipboard contents,
notifications, and files sync to a living-room machine.

## Phase 1 — Install

- [ ] T001 Record the pre-change baseline: GNOME Shell version, package availability and version, firewall state, listening ports, and appliance address. Confirm SSH, autologin, and the desktop are healthy first.
- [ ] T002 Write `scripts/install-gsconnect.sh`: idempotent, installs `gnome-shell-extension-gsconnect` from the Ubuntu repository only, no third-party source, and refuses to run as the wrong user. Verify by running it twice.
- [ ] T003 Enable the extension and confirm it reports as enabled. On Wayland the shell cannot be restarted in place, so this needs a log out and back in, or a reboot; record which was used.

## Phase 2 — Lock down before pairing

- [ ] T004 Apply the plugin policy from `plan.md` **before any phone is paired**: enable `mousepad` only, and explicitly disable `clipboard`, `share`, `sms`, `telephony`, `notification`, `sftp`, `runcommand`, `mpris`, `systemvolume`, `battery`, `ping`, and `findmyphone`. Make this reproducible in a tracked script, not a one-off, and record the rationale for each in the docs.

## Phase 3 — Pair

- [ ] T005 Pair the owner's Android phone through an explicit confirmation on both ends. Confirm no device is trusted implicitly and that an unpaired device cannot inject input.
- [ ] T006 Confirm GSConnect's certificate, private key, and paired-device metadata under `~/.config/gsconnect/` are outside version control, and that `git status` is clean after pairing.

## Phase 4 — Validate the actual goal

- [ ] T007 From the couch, with no physical keyboard or mouse: move the pointer, click, and type into a text field from the phone.
- [ ] T008 Verify remote typing works in **both** Firefox and a Chromium-based browser (Brave is already installed). This is the point of the feature — it proves input no longer depends on the browser cooperating with the compositor's on-screen-keyboard protocol, which is what defeated Spec 009.
- [ ] T009 Enter a password into a streaming-service login field from the phone and confirm the session persists across a browser close and relaunch, completing the acceptance Spec 009 could not finish.

## Phase 5 — Durability and exit

- [ ] T010 Confirm pairing survives a reboot; if it does not, document the reconnection procedure.
- [ ] T011 Document the removal path: unpair the phone, disable or remove the extension, delete `~/.config/gsconnect/`, and confirm SSH, automatic login, and the desktop are unaffected. Verify it, rather than only writing it down.
- [ ] T012 Write `docs/phone-input.md` covering install, the enabled-plugin policy with rationale, pairing, daily use, the known LAN exposure, and removal.
- [ ] T013 Record in `progress.ai` that no firewall is enabled, so no ports were opened, and note that GSConnect would need TCP/UDP `1716-1764` if one is ever added.
- [ ] T014 Record the GNOME 51 compatibility risk (`gnome-shell (<< 51~)`) against Spec 013, since a future release will make this package uninstallable.
- [ ] T015 Run the standard pre-PR checks, update `progress.ai` and `handoff.ai`, and prepare the pull request.

## Explicitly not in this feature

- File transfer, clipboard synchronization, notification mirroring, SMS, and media control.
- Using the phone as the routine navigation device; the DualSense remains the primary couch controller.
- Any change to browser choice, though this feature removes the constraint that forced the Spec 009 switch.
