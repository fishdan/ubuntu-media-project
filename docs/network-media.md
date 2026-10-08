# Network Media Share

The appliance reads media from `nathan` over NFS, mounted read-only at `/media_remote`.
Browse it in GNOME Files or open files in VLC like any local folder.

| | |
|---|---|
| Server | `nathan`, `192.168.1.163`, Ubuntu 26.04.1 LTS |
| Export | `/data/media` (on a 1.8 TB disk, 1.7 TB free) |
| Mount point | `/media_remote` |
| Protocol | NFS 4.2, read-only |
| Measured read | **115 MB/s** cold over gigabit Ethernet |

Add media **on `nathan`**, in `/data/media`. The appliance can read but never write.

## BSG playlist

Open **Battlestar Galactica.xspf** on the desktop. It opens in VLC; VLC's **Next** control
advances to the next video. The playlist contains all 172 BSG MKV files currently on the share.
It follows the owner's watch order: miniseries; Seasons 1–2 through episode 17; Razor minisodes
and Razor; the rest of Season 2; Resistance; Season 3 and Season 4 through episode 11; Face of
the Enemy; Season 4 episodes 12–15; The Plan; the rest of Season 4; and Blood & Chrome.
The Lowdown and the non-narrative featurettes follow at the end.

After adding or removing BSG videos, rebuild the desktop playlist on the appliance:

```bash
python3 scripts/build-bsg-playlist.py
```

The script reads the mounted share and updates the playlist only when its contents change. It
does not write to the read-only share. The playlist uses absolute `/media_remote` paths, so it
works from the desktop while the share is mounted and can trigger the automount when opened.

## Install

Two scripts, because two machines are involved.

```bash
# 1. on the SERVER (run from the appliance, over ssh)
ssh dfish@192.168.1.163 'bash -s' < scripts/configure-media-server.sh

# 2. on the APPLIANCE
bash scripts/install-network-media.sh
```

Both are idempotent. The server script installs `nfs-kernel-server`, creates `/data/media`, and
adds one read-only export for `192.168.1.0/24`. It keeps a recovery copy at
`/etc/exports.before-media-appliance` and refuses to proceed if `/data/media` is already exported
with different options.

## Getting to it without a keyboard

A mount alone is not reachable from the couch -- it would mean typing a path into
Files. Four shortcuts are deployed by the installer and tracked in
`config/applications/media-remote.desktop`:

| Where | What |
|---|---|
| **Files sidebar** | A "Media" bookmark. The most useful of the four: it also appears in every open/save dialog, not only in Files. |
| **Desktop** | A "Media" icon, rendered by the `ding@rastersoft.com` extension. |
| **Dock** | A "Media" favourite. |
| **Activities search** | Searchable as "Media". |

All four run `nautilus /media_remote`. Because touching the path is what triggers
the automount, **clicking any of them is also what brings the share back after the
server has been away** -- there is no separate reconnect step.

The desktop icon carries `metadata::trusted true`, without which GNOME refuses to
launch a desktop entry and shows it as inert. If it ever appears dead, right-click
it and choose Allow Launching.

**The dock favourite is appended to whatever is already there, never set as a whole
list.** That matters: `configure-desktop-home.sh` from Spec 015 sets five
favourites outright, and the live dock had only three because `zuzz.desktop` and
`firefox_firefox.desktop` were removed by hand. Replacing the list would have
silently undone that choice. See the note in that script.

## Why automount and not `/etc/fstab`

**Because an unavailable media server must never block boot or graphical login.** The appliance
logs in automatically and its whole recovery story depends on reaching the desktop and keeping SSH
up. A media server that is switched off has to be a missing folder, not a failed boot.

A plain `fstab` NFS entry is ordered before `local-fs.target`, so a dead server stalls boot until
it times out. `nofail` only makes that stall non-fatal — it does not remove the wait.

The automount mounts **nothing** at boot. The kernel mounts on first access to `/media_remote` and
unmounts after 30 minutes idle. No boot or login unit can depend on something that was never
mounted. The same mechanism gives recovery for free: once the server returns, the next access
mounts it again with no command and no reboot.

Consequently **`media_remote.mount` must never be enabled.** Only `media_remote.automount` is.
The install script checks this and aborts if the mount unit has become enabled, because enabling
it would quietly reintroduce the boot dependency this design exists to avoid.

## Why `soft` and not `hard`

Conventional advice is `hard`, to avoid corrupting interrupted writes. **This mount is read-only,
so there are no writes to corrupt and that reason does not apply.** With `hard`, a server that
disappears mid-playback leaves the player blocked in uninterruptible I/O — on this appliance that
means a frozen full-screen window the PS button cannot close. `soft` turns it into an error the
player can report.

### What `soft` does *not* do, measured rather than assumed

`soft`, `timeo` and `retrans` govern operations on an **already-established** mount. They do **not
bound the initial mount attempt.** With the server unreachable, a manual
`mount -t nfs -o soft,timeo=50,retrans=3` was observed hanging for **60 seconds and still going**,
not failing at the ~15 s the options suggest.

What actually bounds it here is **`TimeoutSec=20` on the mount unit**: systemd terminates the
mount attempt and the unit fails. So the real behaviour with a dead server is that the first
access to `/media_remote` blocks for **up to 20 seconds** and then fails — not 15, and not
forever. Worth knowing before concluding the appliance has hung.

## Read-only, enforced twice

- The export is `ro` on the server, so no client may write.
- The mount is `ro` on the appliance.

Verified by an actual failed write, not by reading options — `touch /media_remote/probe` returns
`Read-only file system` as both root and `dfish`.

This matters because the appliance auto-logs in with no password prompt. Read-only means nobody
with physical access to the living room can delete or alter the library.

`dfish` is uid/gid 1000 on both machines, so ownership maps across NFS with no squashing tricks.
`root_squash` is on, so root here is not root there.

## Security: this feature re-enters the unpatched decode path

The 2026-10-07 audit accepted **20 unpatched Universe/Multiverse security updates**, mostly
media-decode libraries (`libavcodec62`, `libavformat62`, `libde265-0`, `libass9`, `libswscale9`),
after the owner declined Ubuntu Pro. Part of the justification was that the browser is the only
real media path — **Brave has no system `libavcodec` linkage** and Firefox is a confined snap —
and that Kodi and VLC were near-unreachable with no local library.

**Playing files from this share through VLC or Kodi routes them straight through those unpatched
libraries**, and the GNOME/GStreamer thumbnailer will decode them on folder browse without
anything being opened deliberately.

Not a reason to abandon the share: media on the owner's own LAN is a different threat model from
arbitrary internet content, and a malicious file would have to be placed on `nathan` first. But
the risk accepted that morning is not the risk now being run. **If this share ever holds files
from untrusted sources, reconsider Ubuntu Pro.**

Unrelated but worth remembering: `nathan` also runs Caddy and Cloudflare Tunnel, so part of it is
published to the internet. The NFS export is LAN-only; keep `/data/media` out of any tunnel config.

## Troubleshooting

**The folder is empty or errors.** Almost always the server. Check in this order:

```bash
systemctl status media_remote.automount        # should be active (waiting)
systemctl status media_remote.mount            # 'failed (timeout)' means the server is unreachable
timeout 5 bash -c 'echo > /dev/tcp/192.168.1.163/2049' && echo reachable
ssh dfish@192.168.1.163 'systemctl is-active nfs-server; sudo exportfs -s'
```

After a failed attempt the unit stays failed; clear it with
`sudo systemctl reset-failed media_remote.mount`, then access the path again.

**Check for stray firewall rules before blaming NFS.** During development a leftover
`iptables -j DROP` rule on the appliance targeting `192.168.1.163:2049` produced exactly the
symptoms of a dead server — port 111 open, 2049 filtered, mounts timing out — while the server was
entirely healthy and listening. It cost a long diagnosis.

```bash
sudo iptables -S OUTPUT | grep 2049      # should return nothing
```

Such rules are in-memory only unless `iptables-persistent` is installed, which it is not here, so
a reboot clears them.

**The server's address changed.** There is **no DHCP reservation** for `nathan`, and the address is
hardcoded in `config/systemd/system/media_remote.mount`. If the library "disappears", check
`nathan`'s address first. A router-side reservation would remove this fragility and is recommended.

**Playback stutters.** Confirm the wired link: `cat /sys/class/net/enp3s0/speed` should report
1000. Wi-Fi is much slower and is the fallback, not the path this assumes.

## Revert

```bash
bash scripts/install-network-media.sh --revert
```

Disables and removes both units, unmounts if mounted, and removes `/media_remote` if empty.
`nfs-common` is left installed deliberately — removing it could affect anything else using NFS,
and the package alone changes no behaviour.

Verified on 2026-10-07: after a revert, SSH, automatic login, the desktop, GSConnect, the Steam
unit and `media-home.service`'s disabled state were all unaffected, and a reinstall restored the
share.

To remove the export on the server, edit `/etc/exports` there, run `sudo exportfs -ra`, and
optionally `sudo apt-get remove nfs-kernel-server`. The recovery copy of the original file is at
`/etc/exports.before-media-appliance`.

## Test clip

`/media_remote/_test-pattern-1080p.mp4` is a generated 30-second 1080p H.264 clip with a 440 Hz
tone, for checking video and audio through the projector and receiver. Delete it once real media is
in place.
