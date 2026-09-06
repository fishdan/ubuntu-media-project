# Phone and Tablet Remote Input (GSConnect)

Keyboard and pointer input from an Android device, using GSConnect — the GNOME
Shell implementation of the KDE Connect protocol.

This exists because Spec 009 could not make GNOME's on-screen keyboard appear in
a Chromium browser. A captured `WAYLAND_DEBUG` trace showed the browser sending a
protocol-correct `text-input-v3` focus handshake that GNOME Shell did not act on.
Remote input sidesteps that entire class of problem: events are injected at the
input layer, the same way a physical keyboard does, so it does not matter whether
the focused application cooperates with the compositor.

See `specs/0/0.016-gsconnect-remote-input/` for the specification.

## What is installed

- `gnome-shell-extension-gsconnect` `71-1ubuntu1`, from Ubuntu's `universe`
  repository. No third-party package source.
- The phone side is the ordinary **KDE Connect** Android app. There is only one
  Android app; GSConnect is the desktop half.
- The Plasma `kdeconnect` package is deliberately **not** used: it would pull Qt
  and KDE libraries onto a GNOME appliance for no benefit.

```bash
scripts/install-gsconnect.sh
```

Idempotent. On Wayland, GNOME Shell cannot be restarted in place, so a freshly
installed extension is invisible to the running session — the script detects this
and tells you to log out and back in, then enables the extension when re-run.

## Enabled plugins, and why the rest are off

Only `mousepad` — remote pointer and keyboard — is enabled. Everything else is
disabled through the Device schema's `disabled-plugins` list.

| Plugin | Why it is off |
| --- | --- |
| `clipboard` | Two-way clipboard sync. A living-room machine should not receive the phone's clipboard, and passwords typed here should not leave. |
| `share` | Inbound file transfer. Ships **enabled**; out of scope. |
| `sftp` | Exposes phone storage as a mount. Ships with `automount` **enabled**. |
| `notification` | Mirrors personal notifications onto a television. Ships **enabled**. |
| `sms`, `telephony`, `contacts` | Personal messages and contacts on a TV. `contacts-source` ships **enabled**. |
| `runcommand` | Lets the phone execute commands on the appliance. The attack surface is not worth the convenience. |
| `mpris`, `systemvolume` | Media control is the DualSense's job. |
| `battery`, `ping`, `findmyphone`, `presenter` | Not needed for input. |

```bash
scripts/configure-gsconnect.sh --apply     # restrict to remote input
scripts/configure-gsconnect.sh --status    # read back what is actually set
scripts/configure-gsconnect.sh --harden    # stop advertising on the LAN
```

**The policy cannot be applied before pairing.** GSConnect stores plugin state
per device, and no device exists until it is paired. Several defaults are
permissive and live from the moment a device pairs, so run `--apply` immediately
afterwards. `--apply` also clears each risky plugin's own switches, so
re-enabling a plugin by accident does not immediately start moving data.

## Pairing

1. Install **KDE Connect** on the Android device.
2. Put it on the same LAN as the appliance.
3. Open the app, select the appliance, and request pairing.
4. Accept the prompt on the appliance. The DualSense can click it.
5. Immediately run `configure-gsconnect.sh --apply`, then `--harden`.

To pair another device, discovery has to be turned back on first:

```bash
gsettings set org.gnome.Shell.Extensions.GSConnect discoverable true
# pair, then:
scripts/configure-gsconnect.sh --apply     # the policy is per device
scripts/configure-gsconnect.sh --harden
```

## Daily use

In KDE Connect, open the appliance and choose **Remote input**. Drag to move the
pointer, tap to click, and use the device's own keyboard to type. It works in any
application, including Chromium-based browsers.

The DualSense remains the primary couch controller. The phone or tablet is for
text entry and occasional pointer work.

## Network exposure

The appliance runs **no firewall** — `ufw` is inactive and all iptables policies
are `ACCEPT`. GSConnect listens on **TCP and UDP 1716 on all interfaces**, so that
port is reachable from anything on the LAN.

This is acceptable only because pairing requires confirmation at both ends, and
because `--harden` stops the appliance advertising itself. It is recorded here
rather than glossed over. If a firewall is ever enabled, GSConnect needs TCP and
UDP **1716-1764**.

## Credentials

GSConnect's identity lives in `~/.config/gsconnect/`:

- `certificate.pem` — public certificate
- `private.pem` — private key, mode 600

**None of it is in version control**, and neither is the paired device's
identifier. Do not copy them into the repository.

## Removal

**Disabling the extension is not enough.** Verified on 2026-09-05: after
`gnome-extensions disable`, the GSConnect daemon kept running and **port 1716
stayed open and listening on all interfaces**. The daemon is D-Bus activated
through `org.gnome.Shell.Extensions.GSConnect.service` and is parented to
systemd, not to GNOME Shell, so disabling the extension does not stop it. It
exposes no `quit` action either. On a machine with no firewall that leaves a
network listener running while the operator believes the feature is removed.

```bash
# 1. Unpair the device, from the KDE Connect app or GSConnect's preferences.

# 2. Disable the extension:
gnome-extensions disable gsconnect@andyholmes.github.io

# 3. Stop the daemon explicitly - step 2 does not do this.
#    Match on the full path. A loose `pkill -f gsconnect` will also match the
#    shell running the command and kill your own session.
pkill -f '/service/daemon\.js'

# 4. Confirm the port is actually closed:
ss -tuln | grep 1716 || echo "port closed"

# 5. Optionally remove the package and its identity:
sudo apt-get remove --purge gnome-shell-extension-gsconnect
rm -rf ~/.config/gsconnect
```

Verified that disabling the extension leaves SSH, the DualSense pointer service,
automatic login and the desktop-first home unaffected.

Note that `apt-get remove` leaves the 39 dependency packages behind;
`sudo apt-get autoremove` clears them if wanted.

Re-enabling the extension restores the daemon, the listening port, and the
existing pairing — the device stays paired across a disable and re-enable.

## Known limitations

- **GNOME 51 will break this package.** It declares `gnome-shell (>= 46~)` and
  `gnome-shell (<< 51~)`, and the appliance runs GNOME Shell 50.1 — one major
  release below the ceiling. A future upgrade will make it uninstallable until
  Ubuntu ships a newer build. Recorded as a Spec 013 maintenance risk.
- Installing it pulled in **39 packages**, including `folks`, `telepathy-glib`
  and `evolution-data-server` — contacts and telephony stacks that exist to serve
  the plugins this setup disables. Three Evolution services now run
  (~46 MiB total), all D-Bus activated rather than started at boot, none
  listening on the network.
- Discovery relies on UDP broadcast. Networks with client isolation between
  wireless devices will prevent the phone finding the appliance.
