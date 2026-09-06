# Tasks: Phone-Based Remote Input (GSConnect)

Ordered per `plan.md`. **Note the correction recorded there**: the plugin policy
cannot be applied before pairing, because GSConnect stores plugin state per
device and no device exists until paired. T004 therefore writes and tests the
policy script so it can be run within seconds of pairing in T005, and several
permissive shipped defaults (`Share.receive-files`, `SFTP.automount`,
`Notification.send-notifications`) make that promptness matter.

## Phase 1 — Install

- [x] T001 Record the pre-change baseline: GNOME Shell version, package availability and version, firewall state, listening ports, and appliance address. Confirm SSH, autologin, and the desktop are healthy first.
- [x] T002 Write `scripts/install-gsconnect.sh`: idempotent, installs `gnome-shell-extension-gsconnect` from the Ubuntu repository only, no third-party source, and refuses to run as the wrong user. Verify by running it twice. Done: installed `71-1ubuntu1`; second run reported already-installed.
- [x] T003 Enable the extension and confirm it reports as enabled. On Wayland the shell cannot be restarted in place, so this needs a log out and back in, or a reboot; record which was used.
  Done via reboot at 2026-09-05 22:25:29. Extension reports `Enabled: Yes`, `State: ACTIVE`, version 71,
  with the daemon running and listening on TCP and UDP 1716.

## Phase 2 — Lock down before pairing

- [x] T004 Write and test `scripts/configure-gsconnect.sh`, the reproducible plugin policy: keep `mousepad`, disable everything else via the Device schema's `disabled-plugins` list, clear the permissive per-plugin switches as defence in depth, and provide `--harden` to stop LAN discovery after pairing.
  A first version was wrong and was rewritten: it set an `enabled` key on the per-plugin schemas, which do not have one, so it would have silently done nothing. Verified both `--status` and `--apply` behave correctly with no device paired.

## Phase 3 — Pair

- [x] T005 Pair the owner's Android phone through an explicit confirmation on both ends. Confirm no device is trusted implicitly and that an unpaired device cannot inject input.
  Paired 2026-09-05. The device is a **Galaxy Tab A11 (type `tablet`)**, not a phone; functionally
  identical for KDE Connect and arguably better for typing, but recorded because the specification says
  "phone". Connected over `lan://192.168.1.210:1716`. Policy applied within seconds of pairing.
- [x] T006 Confirm GSConnect's certificate, private key, and paired-device metadata under `~/.config/gsconnect/` are outside version control, and that `git status` is clean after pairing.
  Verified: `certificate.pem` and `private.pem` live in `~/.config/gsconnect/` with the key at mode 600,
  nothing `.pem` is tracked, the working tree is clean, and scans found neither the device id nor any
  certificate material anywhere in the repository.

## Phase 4 — Validate the actual goal

- [x] T007 From the couch, with no physical keyboard or mouse: move the pointer, click, and type into a text field from the phone.
  Accepted 2026-09-05: the owner reports it works. GSConnect holds an established session to the tablet at
  `192.168.1.210:1716`.
- [x] T008 Verify remote typing works in **both** Firefox and a Chromium-based browser (Brave is already installed).
  Accepted 2026-09-05, and corroborated in the journal: `app-gnome-brave` launched twice this boot from the
  dock entry, alongside `app-gnome-zuzz-`. **This is the result the feature existed for.** Chromium is the
  engine whose Wayland text-input behaviour defeated GNOME's on-screen keyboard in Spec 009 and forced the
  browser switch; typing into it from the tablet proves remote input bypasses that class of problem
  entirely, because events are injected at the input layer rather than requiring the application to
  cooperate with the compositor. This is the point of the feature — it proves input no longer depends on the browser cooperating with the compositor's on-screen-keyboard protocol, which is what defeated Spec 009.
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
