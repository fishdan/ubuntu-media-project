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

- **Server:** `nathan` at **192.168.1.163**, Ubuntu 26.04.1 LTS, a Linux machine the owner controls.
  **`bubuntu` (192.168.1.10) was evaluated first and rejected on capacity.** The owner recalled a
  terabyte-class disk; `bubuntu` has two disks as remembered, one spinning and one SSD, but the
  spinning one is a 160 GB `WDC WD1600JS` with 139 GB free, not a terabyte. The 1.8 TB disk is on
  `nathan`, mounted at `/data` with **1.7 TB free**. `nathan` is the better host on every axis: far
  more space, the same Ubuntu release as the appliance, and `/data` already mounted `noatime`.
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

## Required inputs — supplied 2026-10-07

1. **Server:** `nathan`, `192.168.1.163`. **No DHCP reservation is known to exist**, and this is
   recorded as a live fragility rather than glossed: the appliance's own address has drifted twice
   in this project, and a server address that drifts would present to the owner as the media
   library vanishing. The mount hardcodes the address.
2. **Export path:** `/data/media`, a new subdirectory of the existing 1.8 TB `/data` mount. A
   subdirectory rather than `/data` itself, so `lost+found` and the pre-existing `projects`
   directory stay out of the share and the disk remains free for other uses.
3. **Local mount point:** `/media_remote`, as the owner specified.
4. **The export did not exist.** Neither candidate server had `nfs-kernel-server` installed and
   neither had an `/etc/exports`. Server-side configuration was therefore required, which the
   original Out of Scope section excluded — **the owner asked for it explicitly on 2026-10-07**, so
   it is now in scope and tracked in `scripts/configure-media-server.sh`.

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
8. The owner can open one desktop playlist in VLC and use Next to advance through every BSG
   video on the mounted share. Narrative videos follow the owner's 2026-10-08 watch order,
   including the optional minisodes and webisodes; non-narrative featurettes follow at the end.
   Rebuilding the playlist after library changes is documented and idempotent.

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
- ~~Configuring the Linux server's exports~~ — **brought into scope on 2026-10-07 at the owner's
  request**, since neither candidate server had NFS installed. Handled by the one deliberately
  server-side script in this repository, `scripts/configure-media-server.sh`, which carries a
  header saying so. Still out of scope: anything else about `nathan`, which runs n8n, Caddy,
  Cloudflare Tunnel, MariaDB, PostgreSQL, Docker and NoMachine that this project does not describe.
- A media library database, scraping, or metadata. This is a folder of files.
- Restoring the retired Kodi-first home. Kodi may *play* from the share; it is not becoming the
  home again.
- Transcoding or remote streaming.
