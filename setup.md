# FishDan Ubuntu Media PC — Setup Guide

## Project Goal

Turn the auction-purchased **HP ENVY Desktop 795-00XX** into a reproducible, remotely managed Ubuntu living-room media appliance.

The target experience is:

- Power on the PC.
- Ubuntu boots and logs in automatically.
- A TV-friendly home interface appears on the projector.
- A **PS5 DualSense controller** is the primary couch remote.
- **Kodi** handles local media and supported streaming add-ons.
- **Brave** launches browser-first services such as **zuzz.tv** in app/kiosk mode.
- **Steam Big Picture** provides controller-friendly casual gaming.
- A controller shortcut can return the user to the media home screen.
- An on-screen keyboard is available when typing is required.
- Day-to-day administration is performed remotely through **VS Code Remote SSH**.
- Configuration is stored in GitHub so the machine can be rebuilt from a clean Ubuntu install.

This repo should be treated as an **installation/configuration project**, not as a one-off sequence of shell commands.

---

# 1. Known Hardware

Auction listing:

- **Manufacturer:** HP
- **Model:** ENVY Desktop 795-00XX
- **Lot:** 50028
- **CPU:** Intel Core i7-8700
  - 6 cores / 12 threads
  - 3.2 GHz base clock
  - Intel UHD 630 integrated graphics
- **RAM:** 16 GB
- **Storage:** 250 GB
- **Optical drive:** DVD
- **Front I/O:** USB, audio, SD reader
- **Networking:** Gigabit Ethernet expected
- **Wireless:** Wi-Fi/Bluetooth likely present, exact adapter to be confirmed
- **Discrete GPU:** rear-panel photo strongly suggests one is installed
  - likely NVIDIA GTX 10-series based on output layout
  - exact model must be detected after boot

Do not assume the exact GPU, Wi-Fi chipset, storage type, or PSU until verified on the machine.

---

# 2. Guiding Principles

## Reproducible

Every meaningful system change should live in this repository when practical.

Prefer:

- shell scripts
- configuration files
- systemd units
- `.desktop` launchers
- documented GNOME settings
- declarative package lists

Avoid undocumented manual changes.

The long-term goal should be approximately:

```bash
git clone <repo-url>
cd <repo>
sudo ./install.sh
```

followed by a small number of documented interactive steps where unavoidable.

## Idempotent

Scripts should be safe to run more than once.

Examples:

- package installation should tolerate packages already being installed
- directories should use `mkdir -p`
- config deployment should overwrite or reconcile intentionally
- services should be enabled only as needed
- scripts should fail clearly when prerequisites are missing

## Recoverable

The appliance should never become difficult to administer.

Maintain:

- SSH access
- Wi-Fi configuration even after wired Ethernet becomes primary
- a normal Ubuntu desktop underneath the appliance UI
- a documented way to exit Kodi / Brave / Steam
- Git history for rollback

## Appliance First

Normal family use should not require knowledge of Linux.

The desired UX is closer to:

> Roku + Kodi + Steam console + browser apps

than:

> desktop PC connected to a projector

---

# 3. Use Spec Kit to Keep the Project Focused

This will be a FishDan project using **Spec Kit**.

Before implementing large features, use Spec Kit to define the desired behavior and acceptance criteria.

Suggested workflow:

1. Define project principles / constitution.
2. Specify one feature at a time.
3. Generate an implementation plan.
4. Break the plan into tasks.
5. Implement and test.
6. Commit working milestones before moving to the next feature.

Do **not** ask the AI assistant to configure the entire appliance in one giant pass.

Recommended feature sequence:

1. Base Ubuntu + remote administration
2. Hardware detection
3. Graphics and HDMI audio
4. Automatic login and appliance startup
5. Kodi
6. DualSense controller
7. Brave / zuzz.tv integration
8. On-screen keyboard
9. Steam Big Picture
10. Home launcher / return-home behavior
11. Boot/recovery polish

A feature should be considered complete only when its acceptance criteria work from the couch.

---

# 4. Initial Ubuntu Installation

Use **Ubuntu 26.04 LTS Desktop**.

Ubuntu Desktop is preferred over Ubuntu Server because this system needs:

- GNOME graphical session
- Bluetooth management
- browser support
- display configuration
- HDMI audio
- on-screen keyboard support
- easy local recovery
- Kodi
- Steam

## Initial physical setup

Before moving the machine into the AV rack:

- connect a monitor
- connect keyboard and mouse
- connect temporary Wi-Fi
- boot from Ubuntu USB installer
- install Ubuntu Desktop
- install SSH
- test remote access
- reboot
- test remote access again

Only after remote administration is proven should the PC move to the AV receiver/projector.

---

# 5. Hostname

The appliance hostname is:

```text
orpheus
```

or another FishDan convention.

Verify:

```bash
hostnamectl
```

If rebuilding the appliance, restore it with:

```bash
sudo hostnamectl set-hostname orpheus
```

---

# 6. Networking

## Temporary setup

Wi-Fi is acceptable for installation and initial configuration.

Inspect networking:

```bash
nmcli device status
```

Inspect adapters:

```bash
lspci | grep -i network
```

## Permanent setup

Use **wired Gigabit Ethernet** once the machine is installed in the AV rack.

Keep Wi-Fi configured as a fallback management path.

The observed NetworkManager interfaces are `enp3s0` for Ethernet and `wlp2s0` for Wi-Fi. Their autoconnect priorities are `100` and `10`, respectively, so Ethernet is preferred whenever its link is available.

Inspect routing:

```bash
ip route
```

Ubuntu should normally prefer Ethernet over Wi-Fi automatically.

## Recommended LAN setup

Create a **DHCP reservation** in the router for this PC.

Reserve an address for `orpheus` using the router and the appropriate interface MAC address. The currently observed Wi-Fi address is:

```text
orpheus -> 192.168.1.203
```

Treat that address as temporary until the router reservation is confirmed. Do not hard-code a static address on Ubuntu unless there is a reason to do so.

---

# 7. SSH Bootstrap

Install SSH immediately after Ubuntu setup:

```bash
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

Verify:

```bash
systemctl status ssh
```

From the development machine:

```bash
ssh dfish@orpheus
```

or:

```bash
ssh dfish@192.168.1.203
```

## SSH keys

Use key authentication.

Example:

```bash
ssh-copy-id <username>@media
```

Confirm that passwordless key authentication works.

## Critical reboot test

Before removing the local keyboard and monitor:

```bash
sudo reboot
```

After reboot, verify that SSH reconnects successfully.

This is a hard prerequisite before installing the box in the AV rack.

---

# 8. VS Code Remote SSH

On the development machine, configure `~/.ssh/config`, selecting its existing private-key path locally:

```sshconfig
Host orpheus
    HostName 192.168.1.203
    User dfish
    IdentityFile ~/.ssh/id_ed25519
```

Update `HostName` if the router assigns a different reserved address. Never copy the laptop's private key into this repository or onto the appliance.

Then connect using the VS Code **Remote - SSH** extension.

The intended development loop is:

1. Sit at the normal development workstation.
2. Connect to `media` through VS Code.
3. Edit this Git repository remotely.
4. Run installation/configuration scripts in the VS Code terminal.
5. Observe the results live on the projector.
6. Commit working changes.

---

# 9. Create the Git Repository

Suggested repository name:

```text
fishdev-media
```

Possible structure:

```text
fishdev-media/
├── README.md
├── setup.md
├── install.sh
├── packages.sh
├── config/
│   ├── kodi/
│   ├── brave/
│   ├── steam/
│   ├── systemd/
│   ├── autostart/
│   └── controller/
├── scripts/
│   ├── hardware-report.sh
│   ├── launch-zuzz.sh
│   ├── launch-browser.sh
│   ├── launch-steam.sh
│   ├── launch-kodi.sh
│   ├── return-home.sh
│   └── controller-setup.sh
├── docs/
│   ├── hardware.md
│   ├── controller-map.md
│   └── recovery.md
└── specs/
```

Keep generated machine-specific secrets and credentials out of Git.

---

# 10. Hardware Discovery

Before installing graphics drivers or making display assumptions, capture the actual hardware.

## CPU

```bash
lscpu
```

## Memory

```bash
free -h
```

## Storage

```bash
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL
```

Determine whether the 250 GB drive is SSD or HDD.

If it is an HDD, replacing it with a SATA SSD is a worthwhile quality-of-life upgrade.

## Graphics

Run:

```bash
lspci | grep -Ei 'vga|3d|display'
```

and:

```bash
sudo lshw -C display
```

If NVIDIA is present:

```bash
nvidia-smi
```

after the appropriate driver is installed.

Do not buy another GPU until the installed card has been identified and tested.

## Network

```bash
lspci | grep -i network
nmcli device status
```

## Bluetooth

```bash
bluetoothctl list
```

## USB

```bash
lsusb
```

## Audio

```bash
wpctl status
```

Store useful output in:

```text
docs/hardware.md
```

---

# 11. AV Receiver and Projector

The permanent physical chain should normally be:

```text
HP ENVY
    |
   HDMI
    |
AV Receiver
    |
   HDMI
    |
Projector
```

This allows the AV receiver to handle audio while forwarding video.

The discrete GPU's HDMI output should normally be preferred if a discrete card is installed.

---

# 12. HDMI Audio

After connecting through the AV receiver:

```bash
wpctl status
```

Also inspect Ubuntu:

```text
Settings -> Sound
```

Select the HDMI/DisplayPort output associated with the connected GPU/receiver.

Test:

- stereo audio
- volume
- receiver detection
- reboot persistence
- suspend/wake behavior

If multichannel audio is desired, test it as a separate feature rather than assuming it works automatically.

---

# 13. Media Codecs

Install standard media support:

```bash
sudo apt install -y ubuntu-restricted-extras
```

Note that this package may present an interactive license screen during installation.

If full automation is desired later, handle this deliberately rather than blindly scripting through it.

---

# 14. Kodi

Kodi is the preferred TV-style shell for:

- local media
- network media
- supported streaming add-ons
- couch-friendly navigation

Install using the packaging method chosen during implementation.

Avoid relying on obsolete or abandoned package repositories.

Kodi should eventually:

- launch fullscreen
- be controller navigable
- act as the primary media home
- return automatically after external apps exit

---

# 15. Local / Network Media

If media is stored on another Linux server, prefer **NFS**.

Install:

```bash
sudo apt install -y nfs-common
```

Example mount point:

```bash
sudo mkdir -p /media/movies
```

Example temporary mount:

```bash
sudo mount server:/path/to/movies /media/movies
```

Permanent mounts should eventually be represented in configuration and documented.

Consider systemd automounts rather than hard blocking boot on unavailable network shares.

---

# 16. Brave Browser

Brave will be used for streaming services that are better supported in a normal browser than through Kodi add-ons.

This is especially important for:

- zuzz.tv
- services with DRM/authentication that are unreliable in community Kodi add-ons
- arbitrary web streaming sites

Use a dedicated **media browser profile** so the living-room box retains its own:

- cookies
- logins
- preferences
- history
- extensions

Example:

```bash
brave-browser \
  --user-data-dir="$HOME/.config/brave-media" \
  --app=https://zuzz.tv/
```

Alternative kiosk mode:

```bash
brave-browser --kiosk https://zuzz.tv/
```

Prefer `--app=` if it provides the desired combination of full-screen feel and sane browser behavior.

---

# 17. zuzz.tv

zuzz.tv is expected to be one of the most frequently used services.

Do **not** force it into Kodi if Brave already provides a reliable experience.

Create a dedicated launcher script such as:

```text
scripts/launch-zuzz.sh
```

The desired behavior:

1. Select **Zuzz** from the home interface.
2. Kodi/home UI gets out of the way.
3. Brave opens directly to zuzz.tv.
4. User navigates with DualSense.
5. Site runs fullscreen / app-style.
6. A controller shortcut closes Zuzz/Brave.
7. Kodi/home UI returns.

Controller design should account for:

- refresh
- browser back
- pointer movement
- click
- fullscreen
- keyboard invocation

because browser sites occasionally require interaction beyond simple D-pad navigation.

---

# 18. Streaming Services Strategy

Do not make "everything must run inside Kodi" a design requirement.

Use the best execution environment for each service.

Conceptually:

```text
Kodi / Home UI
├── Local Movies       -> Kodi
├── Local TV           -> Kodi
├── YouTube            -> Kodi add-on or browser
├── Zuzz               -> Brave
├── Netflix            -> Browser or tested Kodi option
├── Prime Video        -> Browser or tested Kodi option
├── Other Web Service  -> Brave
└── Steam              -> Steam Big Picture
```

The family should not need to care which technology is used underneath.

---

# 19. Steam

Install Steam after the media features are stable.

Use **Steam Big Picture** as the couch gaming interface.

The i7-8700 and 16 GB RAM are more than sufficient for the intended role.

Actual gaming capability depends heavily on the discrete GPU.

Steam should:

- launch from the media home screen
- use DualSense through Steam Input
- launch directly into Big Picture
- return to Kodi/home when exited

Do not let the system-wide controller mapping interfere with Steam's own controller handling.

This should be explicitly tested.

---

# 20. DualSense Controller

The PS5 DualSense is the intended primary remote.

It can be paired with multiple devices and switched between the PS5 and this Ubuntu box.

Confirm Bluetooth first:

```bash
bluetoothctl list
```

Pairing can be handled through GNOME Bluetooth or `bluetoothctl`.

## Proposed Media Mapping

Initial concept:

| Control | Media function |
|---|---|
| D-pad | directional navigation |
| Left stick | directional navigation |
| Right stick | mouse pointer |
| X / Cross | Enter / click |
| Circle | Back / Escape |
| Square | play/pause or contextual action |
| Triangle | Home / contextual action |
| L1 / R1 | previous / next |
| L2 / R2 | volume down / up |
| Touchpad | mouse / pointer support |
| Touchpad press | toggle on-screen keyboard |
| PS button | return to media home |

This is a starting point, not a final requirement.

Test the mapping against:

- Kodi
- Brave
- zuzz.tv
- on-screen keyboard
- Steam

The mapping layer must not break game controls inside Steam.

---

# 21. On-Screen Keyboard

A living-room appliance must not require a physical keyboard for routine text entry.

Options include:

- GNOME's built-in on-screen keyboard
- Onboard
- another gamepad-friendly keyboard if testing proves better

Desired behavior:

- controller shortcut toggles keyboard
- keyboard is visible from across the room
- D-pad/stick can navigate keys
- Cross selects
- Circle cancels
- text entry works in Brave
- it does not unexpectedly obscure video playback

The initial idea is to map **touchpad press** to show/hide the keyboard.

Automatic keyboard appearance on focused browser text fields is desirable but should not be the only way to invoke it.

---

# 22. Mouse / Pointer Emulation

Some websites will not be usable using only keyboard-style navigation.

Provide a pointer mode:

- right stick -> mouse movement
- Cross or trigger -> left click
- Circle -> browser back / Escape
- possibly touchpad -> native pointer movement

This should feel usable from the couch rather than technically functional but frustrating.

---

# 23. Automatic Login

Once SSH and recovery paths are proven, configure GNOME automatic login for the media user.

The intended boot flow is:

```text
Power
  ->
Ubuntu boot
  ->
automatic login
  ->
graphical user session
  ->
media home
```

Do not enable autologin until remote access works reliably.

---

# 24. Appliance Startup

Prefer one of:

- systemd user services
- GNOME autostart `.desktop` entries

over fragile shell commands scattered across login files.

The startup system should be able to:

- wait for the graphical session
- wait for networking if necessary
- start Kodi/home UI
- restart it if it crashes, if appropriate
- avoid restart loops during intentional exits

This should be designed deliberately during the relevant Spec Kit feature.

---

# 25. Home / Return Behavior

A key appliance behavior is a universal **return-home** action.

Conceptual flow:

```text
Kodi Home
   |
   +--> Zuzz / Brave
   |
   +--> Steam
   |
   +--> other external app

PS button
   |
close/minimize external application
   |
return to Kodi/Home
```

Implementation details should be specified before coding.

Potential implementation mechanisms include:

- wrapper launch scripts
- process supervision
- systemd user services
- desktop/window-manager commands
- controller event service

Favor the simplest robust mechanism.

---

# 26. Display Behavior

Configure the projector as the primary display.

Desired behavior:

- correct native resolution
- 60 Hz where appropriate
- no desktop extending onto phantom displays
- no screen blanking during video
- no automatic suspend during normal media use
- predictable recovery after AV receiver/projector power cycling

The AV receiver may cause HDMI hot-plug events.

Explicitly test:

1. PC boots with receiver/projector on.
2. PC boots with receiver off.
3. Receiver is turned off and back on.
4. Projector input changes.
5. PC resumes from sleep if sleep remains enabled.

---

# 27. Power Management

For an appliance, default GNOME desktop power behavior may be undesirable.

Likely goals:

- no automatic suspend while plugged in
- no screen blanking during active use
- manual suspend/shutdown remains available
- predictable wake behavior

Do not disable every power-saving feature blindly. Test based on actual living-room usage.

---

# 28. Recovery / Admin Escape Hatch

Always retain a way to get back to a normal desktop.

Document:

- controller shortcut to quit media shell
- keyboard shortcut if a keyboard is attached
- SSH commands to stop/restart Kodi
- SSH commands to kill Brave
- SSH commands to restart the graphical session if required
- how to disable appliance autostart temporarily

Create:

```text
docs/recovery.md
```

This file should be usable six months later without remembering project history.

---

# 29. Suggested Install Scripts

## `packages.sh`

Responsible only for package installation.

Possible categories:

- SSH
- Git
- NFS client
- media codecs
- Kodi
- Brave
- Steam
- Bluetooth utilities
- controller utilities
- on-screen keyboard dependencies

## `hardware-report.sh`

Collect:

```bash
hostnamectl
lscpu
free -h
lsblk
lspci
lsusb
nmcli device status
wpctl status
```

Write a human-readable report for `docs/hardware.md`.

## `install.sh`

Top-level orchestration only.

Example conceptual behavior:

```text
validate Ubuntu version
install packages
deploy configuration
install launch scripts
install systemd user units
reload services
print remaining manual steps
```

Avoid putting hundreds of unrelated commands into one opaque script.

---

# 30. Secrets and Credentials

Do not commit:

- streaming passwords
- browser profile data
- cookies
- SSH private keys
- API tokens
- GitHub tokens
- Wi-Fi credentials

Add appropriate entries to `.gitignore`.

The browser profile should live outside the repo.

---

# 31. Testing Checklist

## Base OS

- [x] Ubuntu 26.04 LTS installed
- [x] Wi-Fi works
- [ ] Ethernet works
- [x] Ethernet profile is ready and preferred; physical link test awaits AV-rack cabling
- [x] SSH works
- [x] SSH survives unattended headless reboot
- [x] VS Code Remote SSH works
- [x] GitHub repository is present

## Hardware

- [ ] GPU identified
- [ ] correct graphics driver installed
- [ ] Wi-Fi chipset identified
- [ ] Bluetooth works
- [ ] drive type identified
- [ ] HDMI output works
- [ ] HDMI audio works through receiver

## Kodi

- [ ] launches fullscreen
- [ ] starts automatically
- [ ] controller navigation works
- [ ] local/network media plays
- [ ] returns after external app exits

## Zuzz

- [ ] launches directly from home
- [ ] remains logged in
- [ ] video playback works
- [ ] fullscreen/app mode works
- [ ] right-stick pointer is usable
- [ ] controller click works
- [ ] browser back works
- [ ] refresh is accessible
- [ ] keyboard is accessible
- [ ] return-home shortcut works

## DualSense

- [ ] Bluetooth pairing works
- [ ] reconnects after reboot
- [ ] PS5 switching behavior is acceptable
- [ ] Kodi mapping works
- [ ] Brave mapping works
- [ ] on-screen keyboard works
- [ ] Steam does not receive broken mappings

## Steam

- [ ] Steam launches
- [ ] Big Picture launches
- [ ] DualSense recognized
- [ ] test game launches
- [ ] exit returns to home

## Appliance UX

- [ ] no login screen
- [ ] no desktop shown during normal boot
- [ ] readable from couch
- [ ] no keyboard/mouse needed for routine use
- [ ] system survives receiver/projector power cycling
- [ ] SSH remains available for recovery

---

# 32. Initial Build Order

When the PC gets home, use this order.

## Physical bootstrap

```text
1. Connect monitor, keyboard, mouse.
2. Boot Ubuntu 26.04 LTS live USB.
3. Install Ubuntu.
4. Connect Wi-Fi.
5. Update packages.
6. Install OpenSSH server.
7. Verify SSH from development machine.
8. Configure SSH key.
9. Reboot.
10. Verify SSH again.
11. Verify VS Code Remote SSH.
```

## Capture hardware

```text
12. Identify GPU.
13. Identify storage.
14. Identify Wi-Fi/Bluetooth.
15. Identify audio devices.
16. Commit hardware notes.
```

## Move to living room

```text
17. Shut down.
18. Connect Ethernet.
19. Connect GPU HDMI -> AV receiver.
20. AV receiver -> projector.
21. Boot.
22. Verify networking over Ethernet.
23. Verify projector output.
24. Verify HDMI audio.
```

Only then start appliance customization.

---

# 33. First Commands After Install

A useful first-pass command set:

```bash
sudo apt update
sudo apt upgrade -y

sudo apt install -y \
    openssh-server \
    git \
    curl \
    nfs-common

sudo systemctl enable --now ssh

hostnamectl
ip addr
nmcli device status

lscpu
free -h
lsblk -o NAME,SIZE,FSTYPE,LABEL,MOUNTPOINTS,MODEL
lspci | grep -Ei 'vga|3d|display|network'
lsusb
wpctl status
bluetoothctl list
```

Then verify remote access and stop making significant manual changes outside the repository.

---

# 34. Definition of Done

The project is complete when a normal user can:

1. Turn on the AV system and media PC.
2. Arrive at a TV-friendly home interface automatically.
3. Pick up the same DualSense controller used with the PS5.
4. Navigate Kodi.
5. Launch and watch zuzz.tv.
6. Launch other browser streaming services.
7. Bring up an on-screen keyboard without a physical keyboard.
8. Use a pointer when a website requires one.
9. Launch Steam Big Picture.
10. Return to the home interface predictably.
11. Shut down or suspend the box from the couch.
12. Never need to understand that Ubuntu is underneath during normal use.

Meanwhile, an administrator can:

1. Connect over wired or backup Wi-Fi.
2. Open the machine through VS Code Remote SSH.
3. Reproduce configuration from GitHub.
4. Roll back failed changes.
5. Recover from a broken media UI without physically accessing the machine.

---

# 35. Immediate Next Step

When the machine arrives, do **not** begin customizing Kodi or controller mappings immediately.

First milestone:

> **Clean Ubuntu install + working Wi-Fi + working SSH + successful reboot + successful VS Code Remote SSH connection.**

Once that is committed and stable, capture the actual hardware and begin the first Spec Kit feature.
