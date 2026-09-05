#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    printf '%s\n' "Run this installer as root." >&2
    exit 1
fi

packages=(
    evtest
    input-remapper
    joystick
    kodi-peripheral-joystick
)

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes "${packages[@]}"

for package in "${packages[@]}"; do
    dpkg-query -W -f='${Package}\t${Version}\n' "$package"
done

if ! modinfo hid-playstation >/dev/null 2>&1; then
    printf '%s\n' "The kernel hid_playstation module is unavailable." >&2
    exit 1
fi

printf '%s\n' "DualSense support packages and the in-kernel Sony driver are available."
