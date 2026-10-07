# Feature Specification: Network Media Share

**Status:** specified, not started
**Branch:** `feature/0.017-network-media-share`

> **This reintroduces network media, which Spec 015 explicitly retired.** Spec 015 states that
> "NFS and network media were never implemented and are not reintroduced," on the stated basis
> that the appliance "will never hold a local media library." The owner reversed that decision on
> 2026-10-07. The reversal is recorded here as an amendment rather than applied silently, matching
> how the Spec 015 text-scaling reversal was handled.
>
> The original reasoning is not wrong so much as narrow: the appliance still holds no local
> library. The media lives on another machine and is *read* over the LAN. What changes is that
> video now decodes locally again, which has a security consequence recorded below.

## Owner decisions captured 2026-10-07

- **Server:** a Linux machine the owner controls.
- **Protocol:** NFS. No credentials to store, best throughput, and it is what Spec 007 scoped
  before deferring. SMB is explicitly not used, which keeps a credentials file out of the picture
  entirely and so out of any conflict with the constitution's no-secrets rule.
- **Access:** **read-only.** The appliance auto-logs in with no password prompt, so anyone with
  physical access to the living room would otherwise be able to delete or alter the library.
  Read-only makes that impossible from this machine regardless of who is sitting on the couch.

## Environment facts captured 2026-10-07

- `nfs-common`, `cifs-utils` and `autofs` are **absent**. `sshfs` and `gvfs-backends` are present.
- `/etc/fstab` contains no network mounts; `findmnt` reports no active NFS, CIFS or sshfs mounts.
- **VLC and Kodi are both installed**, Kodi retired and disabled but launchable.
- Root filesystem is at **90%, 23 GB free of 233 GB** (`~/Downloads` holds 161 GB). A network
  share sidesteps this rather than worsening it, which is a secondary benefit of this feature.
- Session is GNOME Wayland with automatic login for `dfish`.

## Required inputs, not yet supplied

These block implementation and must be collected before any mount is configured, exactly as
Spec 007 required:

1. The server's **hostname or LAN address**, and whether it has a DHCP reservation. The appliance's
   own address has drifted before, so a server address that drifts would present as the library
   vanishing.
2. The **export path** on the server.
3. The **local mount point** on the appliance.
4. Whether the server's NFS export already exists or must also be configured.

## Acceptance Criteria

1. The media folder appears at a fixed local path and can be browsed in GNOME Files like any
   ordinary folder.
2. A video plays from it, full screen, with correct audio through the projector and receiver.
3. **An unavailable server cannot block boot or graphical login.** Powering the server off, or
   taking it off the network, must still leave the appliance reaching its desktop normally, with
   SSH available. This is the single most important criterion: it is a constitutional requirement
   that recovery paths survive, and a hard `fstab` mount would violate it.
4. The share mounts on demand and recovers on its own once the server returns, with no manual
   command and no reboot.
5. The configuration is tracked in this repository and deployed by an idempotent script, with a
   documented revert.
6. Read-only is enforced and verified by an actual failed write attempt, not by inspecting options.
7. SSH, automatic login, the desktop, GSConnect and the DualSense are unaffected.

## Security consequence that must be recorded, not glossed

The 2026-10-07 audit accepted **20 unpatched Universe/Multiverse security updates** — largely
media-decode libraries (`libavcodec62`, `libavformat62`, `libde265-0`, `libass9`, `libswscale9`
and others) — after the owner declined Ubuntu Pro. That acceptance was justified in part because
the browser is the only real media path and **Brave has no system `libavcodec` linkage** while
Firefox is a confined snap. Kodi and VLC were judged near-unreachable on a machine with no local
library.

**This feature invalidates half of that reasoning.** Playing files from the share through VLC or
Kodi routes them straight through those unpatched libraries, and the GNOME/GStreamer thumbnailer
will decode them automatically on folder browse without anything being opened deliberately.

This is not a reason to abandon the feature. Media on the owner's own LAN is a materially
different threat model from arbitrary internet content, and a malicious file would have to be
placed on the owner's own server first. But the risk accepted this morning is no longer the risk
being run, so:

- The audit entry in `progress.ai` must be amended to say so.
- `docs/` must state that playing local files re-enters the unpatched decode path.
- If the share will ever hold files from untrusted sources, Ubuntu Pro should be reconsidered.
  That is the owner's decision and must not be re-litigated monthly.

## Out of Scope

- Writing to the share, or any download-to-share workflow.
- SMB/CIFS, sshfs, or any protocol other than NFS.
- Configuring the Linux server's exports, unless the owner asks — the server is a separate machine
  and this repository configures the appliance.
- A media library database, scraping, or metadata. This is a folder of files.
- Restoring the retired Kodi-first home. Kodi may *play* from the share; it is not becoming the
  home again.
- Transcoding or remote streaming.
