#!/usr/bin/env bash

set -u
set -o pipefail

section() {
    printf '\n## %s\n' "$1"
}

unavailable() {
    printf '%s\n' "Unavailable: $1"
}

section "System"
printf 'Manufacturer: '
cat /sys/class/dmi/id/sys_vendor 2>/dev/null || unavailable "system manufacturer"
printf 'Product: '
cat /sys/class/dmi/id/product_name 2>/dev/null || unavailable "product name"
printf 'Firmware vendor: '
cat /sys/class/dmi/id/bios_vendor 2>/dev/null || unavailable "firmware vendor"
printf 'Firmware version: '
cat /sys/class/dmi/id/bios_version 2>/dev/null || unavailable "firmware version"
printf 'Kernel: %s\n' "$(uname -sr)"
if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    printf 'Operating system: %s\n' "${PRETTY_NAME:-unknown}"
fi

section "CPU"
if command -v lscpu >/dev/null 2>&1; then
    lscpu | sed -n -E '/^(Architecture|CPU\(s\)|On-line CPU\(s\) list|Model name|Thread\(s\) per core|Core\(s\) per socket|Socket\(s\)):/p'
else
    unavailable "lscpu"
fi

section "Memory"
if command -v free >/dev/null 2>&1; then
    free -h
else
    unavailable "free"
fi

section "Storage devices"
if command -v lsblk >/dev/null 2>&1; then
    lsblk -d -e 7 -o NAME,SIZE,ROTA,TYPE,TRAN,MODEL
else
    unavailable "lsblk"
fi

section "PCI devices and drivers"
if command -v lspci >/dev/null 2>&1; then
    lspci -nnk
else
    unavailable "lspci"
fi

section "Network interfaces"
if command -v nmcli >/dev/null 2>&1; then
    nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status
else
    unavailable "nmcli"
fi

section "Bluetooth controllers"
if command -v bluetoothctl >/dev/null 2>&1; then
    bluetoothctl list 2>/dev/null \
        | sed -E 's/(Controller )[0-9A-Fa-f:]{17}/\1[redacted]/g'
else
    unavailable "bluetoothctl"
fi

section "USB devices"
if command -v lsusb >/dev/null 2>&1; then
    lsusb
else
    unavailable "lsusb"
fi

section "Audio devices"
if command -v wpctl >/dev/null 2>&1; then
    wpctl status \
        | sed -E 's/cookie:[0-9]+/cookie:[redacted]/g; s/pid:[0-9]+/pid:[runtime]/g'
else
    unavailable "wpctl"
fi

section "NVIDIA status"
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
else
    unavailable "nvidia-smi"
fi

section "Privacy note"
printf '%s\n' "This report intentionally omits host serial numbers, MAC addresses, IP addresses, filesystem UUIDs, and credentials."
