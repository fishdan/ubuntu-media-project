# Tasks: Network Media Share

Ordered per `plan.md`. **T002 blocks everything after it**: no mount may be configured before the
server, export and local path are explicitly supplied, which is the constraint Spec 007 set and
then never got to use.

**T008 must precede owner acceptance.** The failure mode has to be proven from a shell before the
owner is asked to rely on the share from the couch, or a dead server would be discovered as a
failed boot in the living room.

## Phase 1 — Baseline and inputs

- [x] T001 Record the pre-change baseline: `nfs-common`/`cifs-utils`/`autofs` absent, no network
  mounts in `fstab` or `findmnt`, free disk, Ethernet vs Wi-Fi link state, and that SSH, automatic
  login and the desktop are healthy.
- [x] T002 **Collect the required inputs and stop until they are supplied:** server hostname or
  address (and whether it has a DHCP reservation), export path, local mount point, and whether the
  server's export already exists. Record them in this feature's artifacts.

## Phase 2 — Install and mount

- [x] T003 Write `scripts/install-network-media.sh`: idempotent, installs `nfs-common` from Ubuntu
  `main` only, refuses to run as the wrong user, and fails clearly. Verify by running it twice.
- [x] T004 Confirm the export is actually reachable from the appliance before configuring anything
  persistent — `showmount -e <server>` and a throwaway manual read-only mount, then unmount.
- [x] T005 Write the tracked `<escaped-path>.mount` and `<escaped-path>.automount` units: `ro`,
  `noatime`, `soft` with bounded `timeo`/`retrans`, and a generous `TimeoutIdleSec`. Deploy them
  through the install script. Verify with `systemd-analyze verify`.
- [x] T006 Confirm mount-on-access works: the path is unmounted at rest, mounts on first `ls`, and
  appears in `findmnt` with `ro` present in the live options.
- [x] T007 **Verify read-only by attempting a write that must fail.** Reading the mount options is
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

- [x] T013 **Amend the 2026-10-07 security audit entry in `progress.ai`.** That entry accepted 20
  unpatched media-decode libraries partly because no local library existed and the browser path
  does not link them. This feature re-enters that decode path through VLC, Kodi and the GStreamer
  thumbnailer. The accepted risk has changed and the record must say so rather than stand as
  written.
- [x] T014 Write `docs/network-media.md`: the inputs used, why automount rather than `fstab`, why
  `soft` rather than `hard`, the read-only rationale, the amended security position, troubleshooting
  for a server that is off or has changed address, and the revert.
- [x] T015 Amend `specs/0/0.015-desktop-first-home/spec.md` to note that its "network media is not
  reintroduced" statement was superseded on 2026-10-07, so the two specifications do not contradict
  each other for the next reader.
- [x] T016 Document the revert and verify it: remove the units, optionally remove `nfs-common`, and
  confirm SSH, automatic login, the desktop, GSConnect and the DualSense are unaffected.
- [x] T017 Pre-PR checks: secret scan including Bluetooth-address-shaped strings, `bash -n` on all
  tracked scripts, `systemd-analyze verify` on all units, `git diff --check`; update `progress.ai`
  and `handoff.ai`; open the pull request.

## Explicitly not in this feature

- Writing to the share, or downloading into it.
- SMB/CIFS, sshfs, or any non-NFS protocol.
- Configuring the server's exports.
- A media library database, scraping, or metadata.
- Restoring the Kodi-first home. Kodi may play from the share; it is not becoming the home again.

## Completion evidence 2026-10-07

- **T001/T002** — Baseline: `nfs-common`/`cifs-utils`/`autofs` absent, no network mounts, appliance
  at `192.168.1.204` on wired `enp3s0` at 1000 Mb/s, SSH and desktop healthy. Inputs settled as
  `nathan` `192.168.1.163`, export `/data/media`, mount `/media_remote`, export did not exist.
- **T003** — `scripts/install-network-media.sh` and `scripts/configure-media-server.sh`, both run
  twice and confirmed no-ops on the second run. A real idempotency bug was found and fixed: the
  appliance script `chown`ed the mount point unconditionally, which fails with `EROFS` once the
  read-only share is mounted over it and aborted the script under `set -e`. It now skips
  permission enforcement while mounted.
- **T004** — `showmount -e` lists the export; a throwaway manual mount succeeded and negotiated
  NFS 4.2.
- **T005** — Units verify clean under `systemd-analyze verify`. `media_remote.mount` is `static`
  and deliberately has no `[Install]`; only the automount is enabled.
- **T006** — Mount-on-access confirmed: unmounted at rest, mounts on first access, and
  `/proc/mounts` shows the autofs trigger with the NFS mount beneath it.
- **T007** — Read-only proven by failure, not inspection: `touch` returns `Read-only file system`
  as both root and `dfish`.
- **Throughput, measured** — 115 MB/s cold sequential read (cache dropped), roughly 920 Mbit/s and
  near line rate on the gigabit link. Content verified end to end: `md5sum` through NFS matches the
  file on `nathan` byte for byte.
- **T016** — Revert run live, then reinstalled. After revert both units and `/media_remote` were
  gone, nothing was still mounted, and SSH, automatic login, the desktop, GSConnect, the Steam unit
  and `media-home.service`'s disabled state were all verified unaffected.

### A self-inflicted outage that produced a real finding

A leftover `iptables ... --dport 2049 -j DROP` rule on the appliance, created by an abandoned
attempt at the T008 failure simulation, blocked NFS and produced a convincing imitation of a dead
server: port 111 open, 2049 filtered, mounts timing out, while `nathan` was healthy and listening
on `0.0.0.0:2049` the whole time. Diagnosis was long because the server looked guilty. Recorded in
`docs/network-media.md` as the first troubleshooting check.

It did yield something genuinely useful that was otherwise going to be assumed:

**`soft` does not bound the initial mount attempt.** With the server unreachable, a manual mount
with `soft,timeo=50,retrans=3` hung past **60 seconds**, not the ~15 s those options imply. Those
options apply to operations on an established mount. What actually bounds the failure here is
`TimeoutSec=20` on the mount unit. So a dead server means the first access blocks for up to 20
seconds and then fails — a correction to what `plan.md` assumed.

## Still open — and why

- **T008 (reboot with the server unreachable)** — not run. It is the most important check in this
  feature and it needs a reboot, which would end the remote session before the result could be
  verified. **Not claimed.** The dependency structure was inspected instead and supports the
  design: `media_remote.mount` is `static` with nothing but the automount referencing it, and the
  automount's activation is server-independent. That is an argument, not evidence.
- **T009 (self-recovery)** — partially shown. Access succeeded immediately once the stray firewall
  rule was removed, with no manual mount command, which is the recovery path working. Not the
  intended test of powering the server down and back up.
- **T010 (server disappears mid-playback)** — not run; needs playback on the display.
- **T011/T012 (owner acceptance)** — need the owner in the living room. A test clip,
  `_test-pattern-1080p.mp4`, is in place so playback and audio can be checked immediately.
- **T017** — complete. Secret scan clean including Bluetooth-address-shaped strings; all tracked scripts pass `bash -n`; mount, automount and user units verify clean; `git diff --check` clean.
