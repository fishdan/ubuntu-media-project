# Quickstart: Hardware Inventory

Run from the repository root on the appliance.

## Generate a transient report

```bash
bash -n scripts/hardware-report.sh
scripts/hardware-report.sh
```

Review the terminal output and update `docs/hardware.md` with stable findings. Do not redirect raw output into the repository until it has been reviewed for unique identifiers.

## Validate documented findings

```bash
lscpu
free -h
lsblk -d -o NAME,SIZE,ROTA,TYPE,TRAN,MODEL
lspci -nnk
lsusb
nmcli -t -f DEVICE,TYPE,STATE device status
bluetoothctl list
wpctl status
```

Optional vendor or summary tools may add evidence when installed:

```bash
nvidia-smi
inxi -Fazy
```

## Privacy and safety review

Confirm the tracked report contains no private keys, credentials, serial numbers, MAC addresses, IP addresses, filesystem UUIDs, or Wi-Fi secrets. Confirm the script uses no mutating commands such as package installation, service changes, driver changes, or NetworkManager modification.

## Acceptance

The feature is complete when the script runs safely and repeatedly, `docs/hardware.md` covers every required hardware category with evidence and uncertainty labels, and the privacy scan passes.
