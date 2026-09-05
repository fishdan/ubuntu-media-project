# FishDan Ubuntu Media PC

This repository turns an HP ENVY Desktop 795-00XX into a reproducible, remotely managed Ubuntu 26.04 LTS living-room media appliance.

Power it on and it logs in automatically and arrives at a couch-legible GNOME desktop on the projector, where a PS5 DualSense controller launches browser streaming and Steam Big Picture. An administrator must still be able to manage and recover it remotely with SSH and VS Code Remote SSH.

> **2026-09-05 direction change.** The appliance was originally designed around Kodi as a full-screen media home. The owner confirmed it will never hold a local media library, which left Kodi acting only as a launcher shell, so Spec 015 retired the Kodi-first home in favour of the ordinary GNOME desktop. This deleted the session stop/restore orchestration that had been the appliance's most failure-prone component. Kodi stays installed and launchable, and the change reverts with a single command.

## What we are building

- The GNOME desktop as the home experience, scaled and curated for projector viewing distance.
- Firefox in a dedicated media profile for browser-first services, including zuzz.tv.
- Steam Big Picture for controller-friendly casual gaming.
- DualSense navigation and pointer support for couch use; text entry via a phone rather than an on-screen keyboard.
- Closing the active application as the return-home action, since the desktop is always underneath.
- Automatic login and deliberate appliance startup only after remote recovery has been proven.
- HDMI video and audio through the AV receiver to the projector, with stable behavior during AV power changes.
- Scripts and configuration that can rebuild the appliance from a clean Ubuntu installation.

## How we will build it

We will implement one SpecKit feature at a time, in order, and commit a working milestone before beginning the next. Scripts will be idempotent; package lists, launchers, systemd user units, and configuration will live in this repository where practical. Hardware facts will be captured from the actual machine before driver or display decisions are made.

The first hands-on milestone is intentionally conservative: install Ubuntu, prove Wi-Fi and SSH, configure SSH keys, reboot, prove SSH again, and connect using VS Code Remote SSH. Only then does the PC move to the AV rack or receive appliance customization.

## Planned delivery order

| Order | Feature | Outcome |
| --- | --- | --- |
| 1 | Base Ubuntu and remote administration | Ubuntu 26.04, networking, SSH, reboot recovery, and VS Code Remote SSH work. |
| 2 | Hardware inventory | Actual GPU, storage, network, Bluetooth, USB, and audio facts are recorded. |
| 3 | Graphics, AV display, HDMI audio, and power | Projector/receiver output is stable and recoverable. |
| 4 | Automatic login and appliance startup | The graphical session reaches a controlled media home without sacrificing recovery. |
| 5 | ~~Kodi and local/network media~~ | Superseded by the desktop-first home. Kodi remains installed but is no longer the home. |
| 6 | DualSense controller | Navigation mappings work without breaking Steam Input. |
| 7 | Firefox and zuzz.tv | Browser-first streaming launches in kiosk mode and exits to the desktop. |
| 8 | Pointer and text entry | Pointer is covered by the DualSense mapping; text entry moves to phone-based remote input. |
| 9 | Steam Big Picture | Steam is controller-friendly and exits predictably to home. |
| 10 | ~~Home launcher and universal return~~ | Superseded by the desktop-first home; closing the application is the return. |
| 11 | Boot, recovery, and reproducibility polish | The appliance survives normal failures and can be rebuilt from Git. |

The corresponding lightweight specs are in [`specs/0/`](specs/0/). Full acceptance criteria, plans, and tasks will be written only when work begins on a feature.

## Current administration baseline

The appliance is named `orpheus` and runs Ubuntu 26.04.1 LTS. OpenSSH starts automatically, ED25519 key authentication and VS Code Remote SSH have been validated from a separate administrator laptop, and remote access has survived an unattended boot with no keyboard or monitor attached.

NetworkManager prefers the `enp3s0` Ethernet profile when a cable is available and retains the `Machine Network` Wi-Fi profile on `wlp2s0` as the management fallback. Use a router-side DHCP reservation rather than configuring a static address on Ubuntu. The currently observed Wi-Fi address, `192.168.1.203`, is operational evidence and may change until the router reservation is applied.

For recovery, reconnect a monitor and keyboard to use the normal GNOME desktop or a local TTY. Do not remove Wi-Fi fallback or local-console access while changing appliance startup behavior.

## Non-negotiable safeguards

- Do not configure autologin or automatic media startup until SSH works after a reboot.
- Do not assume the installed GPU, Wi-Fi, Bluetooth, storage, or HDMI behavior; inspect and record it first.
- Keep wired Ethernet as the normal connection and configured Wi-Fi as management fallback.
- Keep a normal Ubuntu desktop and documented SSH recovery path available.
- Never commit streaming logins, browser profiles/cookies, Wi-Fi credentials, private keys, or tokens.

See [setup.md](setup.md) for the detailed setup guide and [start.ai](start.ai) for the required AI-assisted development workflow.
