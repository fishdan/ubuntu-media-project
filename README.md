# FishDan Ubuntu Media PC

This repository turns an HP ENVY Desktop 795-00XX into a reproducible, remotely managed Ubuntu 24.04 LTS living-room media appliance.

The finished system should feel like a console-style home interface, not a desktop PC: power it on, arrive at a TV-friendly media home on the projector, and use a PS5 DualSense controller for Kodi, browser streaming, and Steam Big Picture. An administrator must still be able to manage and recover it remotely with SSH and VS Code Remote SSH.

## What we are building

- Kodi as the primary full-screen home for local/network media and suitable add-ons.
- Brave in a dedicated media profile for browser-first services, including zuzz.tv.
- Steam Big Picture for controller-friendly casual gaming.
- DualSense navigation, pointer support, and an on-screen keyboard for couch use.
- A universal controller action that returns from Brave, Steam, or another external app to the media home.
- Automatic login and deliberate appliance startup only after remote recovery has been proven.
- HDMI video and audio through the AV receiver to the projector, with stable behavior during AV power changes.
- Scripts and configuration that can rebuild the appliance from a clean Ubuntu installation.

## How we will build it

We will implement one SpecKit feature at a time, in order, and commit a working milestone before beginning the next. Scripts will be idempotent; package lists, launchers, systemd user units, and configuration will live in this repository where practical. Hardware facts will be captured from the actual machine before driver or display decisions are made.

The first hands-on milestone is intentionally conservative: install Ubuntu, prove Wi-Fi and SSH, configure SSH keys, reboot, prove SSH again, and connect using VS Code Remote SSH. Only then does the PC move to the AV rack or receive appliance customization.

## Planned delivery order

| Order | Feature | Outcome |
| --- | --- | --- |
| 1 | Base Ubuntu and remote administration | Ubuntu 24.04, networking, SSH, reboot recovery, and VS Code Remote SSH work. |
| 2 | Hardware inventory | Actual GPU, storage, network, Bluetooth, USB, and audio facts are recorded. |
| 3 | Graphics, AV display, HDMI audio, and power | Projector/receiver output is stable and recoverable. |
| 4 | Automatic login and appliance startup | The graphical session reaches a controlled media home without sacrificing recovery. |
| 5 | Kodi and local/network media | Kodi is a controller-friendly media home with recoverable network-media support. |
| 6 | DualSense controller | Navigation mappings work without breaking Steam Input. |
| 7 | Brave and zuzz.tv | Browser-first streaming launches in app-style mode and returns home cleanly. |
| 8 | On-screen keyboard and pointer | Text and websites remain usable without a physical keyboard or mouse. |
| 9 | Steam Big Picture | Steam is controller-friendly and exits predictably to home. |
| 10 | Home launcher and universal return | One controller action reliably restores the media home. |
| 11 | Boot, recovery, and reproducibility polish | The appliance survives normal failures and can be rebuilt from Git. |

The corresponding lightweight specs are in [`specs/0/`](specs/0/). Full acceptance criteria, plans, and tasks will be written only when work begins on a feature.

## Non-negotiable safeguards

- Do not configure autologin or automatic media startup until SSH works after a reboot.
- Do not assume the installed GPU, Wi-Fi, Bluetooth, storage, or HDMI behavior; inspect and record it first.
- Keep wired Ethernet as the normal connection and configured Wi-Fi as management fallback.
- Keep a normal Ubuntu desktop and documented SSH recovery path available.
- Never commit streaming logins, browser profiles/cookies, Wi-Fi credentials, private keys, or tokens.

See [setup.md](setup.md) for the detailed setup guide and [start.ai](start.ai) for the required AI-assisted development workflow.
