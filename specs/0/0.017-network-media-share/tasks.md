# Tasks: Network Media Share

Ordered per `plan.md`. **T002 blocks everything after it**: no mount may be configured before the
server, export and local path are explicitly supplied, which is the constraint Spec 007 set and
then never got to use.

**T008 must precede owner acceptance.** The failure mode has to be proven from a shell before the
owner is asked to rely on the share from the couch, or a dead server would be discovered as a
failed boot in the living room.

## Phase 1 — Baseline and inputs

- [ ] T001 Record the pre-change baseline: `nfs-common`/`cifs-utils`/`autofs` absent, no network
  mounts in `fstab` or `findmnt`, free disk, Ethernet vs Wi-Fi link state, and that SSH, automatic
  login and the desktop are healthy.
- [ ] T002 **Collect the required inputs and stop until they are supplied:** server hostname or
  address (and whether it has a DHCP reservation), export path, local mount point, and whether the
  server's export already exists. Record them in this feature's artifacts.

## Phase 2 — Install and mount

- [ ] T003 Write `scripts/install-network-media.sh`: idempotent, installs `nfs-common` from Ubuntu
  `main` only, refuses to run as the wrong user, and fails clearly. Verify by running it twice.
- [ ] T004 Confirm the export is actually reachable from the appliance before configuring anything
  persistent — `showmount -e <server>` and a throwaway manual read-only mount, then unmount.
- [ ] T005 Write the tracked `<escaped-path>.mount` and `<escaped-path>.automount` units: `ro`,
  `noatime`, `soft` with bounded `timeo`/`retrans`, and a generous `TimeoutIdleSec`. Deploy them
  through the install script. Verify with `systemd-analyze verify`.
- [ ] T006 Confirm mount-on-access works: the path is unmounted at rest, mounts on first `ls`, and
  appears in `findmnt` with `ro` present in the live options.
- [ ] T007 **Verify read-only by attempting a write that must fail.** Reading the mount options is
  not sufficient evidence; the acceptance criterion is an actual `EROFS`.

## Phase 3 — Prove the failure mode before the couch depends on it

- [ ] T008 **With the server unreachable, reboot the appliance.** The desktop must still come up
  with automatic login and SSH must still be available. Record boot time and that no unit waited
  on the share. This is the constitutional requirement and the single most important check here.
- [ ] T009 Confirm self-recovery: with the appliance still running, bring the server back and
  confirm the folder works again on next access with **no manual command and no reboot**.
- [ ] T010 Confirm a server that disappears *mid-playback* surfaces an error the player can report
  rather than an unkillable process, and that the PS button still returns home afterwards. This is
  what the `soft` option was chosen for and it should be tested rather than assumed.

## Phase 4 — Owner acceptance

- [ ] T011 Owner browses the share in GNOME Files at the fixed path and it behaves like an ordinary
  folder.
- [ ] T012 Owner plays a video full screen from the share with correct audio through the projector
  and receiver. Judge playback honestly, including any stutter over the network, and record whether
  the link was Ethernet or Wi-Fi.

## Phase 5 — Document and close

- [ ] T013 **Amend the 2026-10-07 security audit entry in `progress.ai`.** That entry accepted 20
  unpatched media-decode libraries partly because no local library existed and the browser path
  does not link them. This feature re-enters that decode path through VLC, Kodi and the GStreamer
  thumbnailer. The accepted risk has changed and the record must say so rather than stand as
  written.
- [ ] T014 Write `docs/network-media.md`: the inputs used, why automount rather than `fstab`, why
  `soft` rather than `hard`, the read-only rationale, the amended security position, troubleshooting
  for a server that is off or has changed address, and the revert.
- [ ] T015 Amend `specs/0/0.015-desktop-first-home/spec.md` to note that its "network media is not
  reintroduced" statement was superseded on 2026-10-07, so the two specifications do not contradict
  each other for the next reader.
- [ ] T016 Document the revert and verify it: remove the units, optionally remove `nfs-common`, and
  confirm SSH, automatic login, the desktop, GSConnect and the DualSense are unaffected.
- [ ] T017 Pre-PR checks: secret scan including Bluetooth-address-shaped strings, `bash -n` on all
  tracked scripts, `systemd-analyze verify` on all units, `git diff --check`; update `progress.ai`
  and `handoff.ai`; open the pull request.

## Explicitly not in this feature

- Writing to the share, or downloading into it.
- SMB/CIFS, sshfs, or any non-NFS protocol.
- Configuring the server's exports.
- A media library database, scraping, or metadata.
- Restoring the Kodi-first home. Kodi may play from the share; it is not becoming the home again.
