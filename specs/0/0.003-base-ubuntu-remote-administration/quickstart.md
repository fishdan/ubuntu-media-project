# Quickstart: Base Ubuntu and Remote Administration

The repository lives on the appliance itself. The procedure below records the validated baseline and can be repeated after recovery or rebuild. Do not commit private keys, Wi-Fi passwords, or connection profiles.

## Prerequisites

- Physical access to the Ubuntu desktop
- A separate laptop or client on the same network for the later remote-access phase
- A client SSH key created on that laptop, or a way to create one there
- Router access for a DHCP reservation

## Validated values

- Appliance hostname: `orpheus`
- Administrator account: `dfish`
- Ethernet interface/profile: `enp3s0` / `netplan-enp3s0`, autoconnect priority `100`
- Wi-Fi fallback interface/profile: `wlp2s0` / `Machine Network`, autoconnect priority `10`
- Currently observed appliance address: `192.168.1.203`
- Validated administrator-client address: `192.168.1.235`

The address is not a credential, but it remains environment-specific. Apply a router-side DHCP reservation for `orpheus`; do not configure a host-side static address merely to preserve this observed value.

## 1. Capture the installed baseline

On the appliance:

```bash
. /etc/os-release
printf '%s\n' "$PRETTY_NAME ($VERSION_CODENAME)"
hostnamectl
nmcli device status
ip -brief address
```

Record the actual OS, hostname, interfaces, and addresses in the feature's implementation evidence. The approved project baseline is Ubuntu 26.04 LTS, and this host currently reports Ubuntu 26.04.1 LTS.

## 2. Establish the network decision

- Connect Ethernet when available.
- Confirm NetworkManager prefers the wired connection.
- Keep the known Wi-Fi profile configured as fallback.
- Reserve the chosen DHCP address in the router using the appliance MAC address.
- Confirm the hostname resolves from the administrator client, or record the reserved address as the temporary connection target.

## 3. Install and validate OpenSSH

On the appliance:

```bash
sudo apt update
sudo apt install --yes openssh-server
sudo systemctl enable --now ssh
systemctl is-enabled ssh
systemctl is-active ssh
ss -ltnp | grep ':22 '
```

From a separate laptop, copy only its public key through an approved secure method and test key authentication:

```bash
ssh-copy-id dfish@orpheus
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no dfish@orpheus true
```

Do not disable password authentication until the key-based test succeeds and local console recovery is confirmed.

## 4. Prove unattended headless boot and reboot recovery

After a separate laptop has passed the pre-reboot SSH check, disconnect the keyboard and monitor from the appliance. Leave its network connection and power connected. From the authenticated SSH session or local console, reboot the appliance:

```bash
sudo reboot
```

After the host has completed its normal boot without keyboard or monitor attached, from the separate client run:

```bash
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no dfish@orpheus 'hostnamectl --static; systemctl is-active ssh; nmcli -t -f DEVICE,STATE device'
```

The command must return the expected hostname, `active` for SSH, and an available network connection. Reconnect the peripherals afterward and confirm the normal Ubuntu desktop remains available for recovery. A failure blocks all later appliance customization.

## 5. Validate VS Code Remote - SSH

From the administrator client, connect to `dfish@orpheus` with the VS Code Remote - SSH extension. Open the repository or the administrator home directory and run:

```bash
hostnamectl --static
. /etc/os-release
printf '%s\n' "$PRETTY_NAME"
```

The remote terminal must identify the appliance, and the local Ubuntu desktop must remain available at the physical console.

## Recovery procedure

If remote access fails, reconnect a monitor and keyboard. Use the normal GNOME session or switch to a text console with `Ctrl`+`Alt`+`F3`, sign in as the local administrator, and inspect:

```bash
systemctl status ssh
nmcli device status
ip route
journalctl -u ssh -b
```

Restore the known Wi-Fi fallback through NetworkManager if Ethernet is unavailable. Do not delete the working Wi-Fi profile while troubleshooting Ethernet. Re-enable SSH with `sudo systemctl enable --now ssh` if necessary. Reboot only after local networking and the SSH service are healthy.

## Acceptance result

Spec 003 was accepted on 2026-09-04 with Ubuntu 26.04.1 LTS, hostname `orpheus`, working Wi-Fi fallback, Ethernet preference configured, successful key-only login before and after an unattended headless reboot, working VS Code Remote SSH, and a functioning local graphical recovery path. The router-side DHCP reservation remains an external router-administration action; no host-side static address is configured.
