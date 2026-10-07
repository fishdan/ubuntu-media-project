# Implementation Plan: Network Media Share

## Approach

Install `nfs-common`, then mount the server's export **read-only via a systemd automount unit**,
not via `fstab`. A tracked idempotent script deploys the units and a documented revert removes
them. GNOME Files and VLC then treat the mount point as an ordinary folder, which is the whole of
the owner's request.

## The one hard requirement everything else bends around

**An unavailable server must never block boot or graphical login.** The appliance automatically
logs into a desktop and its recovery story depends on reaching that desktop and on SSH staying up.
A media server that is powered off must be a missing folder, not a failed boot.

This rules out the obvious approach. A plain `fstab` NFS entry is ordered before
`local-fs.target`, so a dead server stalls boot until it times out. Even `nofail` only stops it
being fatal — it does not stop the wait.

**`systemd.automount` is the right mechanism, for a specific reason:** nothing mounts at boot at
all. The kernel mounts on first access to the path and unmounts again after an idle timeout. If
the server is down, the access fails and the folder is empty — boot is untouched because no boot
unit ever depended on it. This is also why it self-heals: the next access after the server returns
mounts it again, satisfying the "no manual command, no reboot" criterion for free.

Units needed, named after the escaped mount path:

- `<escaped-path>.mount` — the mount itself, `ro`, `noatime`, with `soft` and a bounded
  `timeo`/`retrans` so a hung server surfaces an I/O error instead of an unkillable process.
- `<escaped-path>.automount` — the trigger, with `TimeoutIdleSec` so idle mounts drop.

**`soft` over `hard` is a deliberate trade and worth stating.** `hard` is the usual advice because
it avoids data corruption on interrupted writes — but this mount is read-only, so there are no
writes to corrupt. With `hard`, a server that vanishes mid-playback leaves VLC blocked in
uninterruptible I/O, which on this appliance means a frozen full-screen window that the PS button
cannot close. `soft` turns that into an error the player can report. For a read-only media share
that is strictly better.

## Read-only must be enforced server-side too

Mounting `ro` stops this machine writing, which satisfies the owner's decision. It does not stop a
*different* machine writing, and it is only as durable as the mount options staying correct. The
export should also be `ro` on the server. Belt and braces, and the acceptance test is an actual
attempted write that must fail — not a reading of the options.

## Sequencing

1. Baseline: record absent packages, no network mounts, free disk, SSH and desktop healthy.
2. Collect the four required inputs. **Blocks everything after it.**
3. Install `nfs-common` idempotently; confirm the export is visible from the appliance.
4. Write the automount units and the install script; deploy; verify mount-on-access.
5. Prove the failure mode: server unreachable, then reboot. Desktop and SSH must be fine.
6. Prove recovery: server returns, folder works again with no intervention.
7. Owner acceptance: browse in Files, play a video full screen with audio through the receiver.
8. Document, including the amended security position, and the revert.

## Risks

- **A drifting server address presents as "my media disappeared."** The appliance's own DHCP
  address has drifted twice in this project. Prefer a hostname with a DHCP reservation, and if an
  address is used, record it as a known fragility rather than pretending it is stable.
- **Idle unmount during a long pause.** `TimeoutIdleSec` set too low could unmount under a paused
  player. Set it generously; a mounted idle NFS share costs nothing.
- **GStreamer thumbnailing a large library on first browse** can spike CPU and I/O, and now also
  runs untrusted-ish files through unpatched decoders. Worth knowing before pointing Files at a
  folder of thousands of videos.
- **Wi-Fi fallback is much slower than Ethernet for video.** The appliance has both; the wired link
  is the one this feature assumes.

## Out of scope

Everything in the specification's Out of Scope section, and in particular: this plan does not
configure the server. If the owner wants the export created too, that is a separate decision and
a separate task list, because it changes a machine this repository does not describe.
