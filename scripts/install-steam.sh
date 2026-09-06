#!/usr/bin/env bash

# Spec 011: install Steam from Ubuntu's multiverse repository.
#
# Two things a future maintainer should know, because a tidy installer can imply
# more than it delivers:
#
#   1. This enables the i386 architecture. Steam needs a parallel 32-bit library
#      stack, which widens the installed surface system-wide.
#   2. `steam-installer` is a BOOTSTRAP. Ubuntu ships the launcher and the 32-bit
#      libraries; the Steam client itself is then downloaded from Valve on first
#      run and self-updates outside APT. "Installed from the Ubuntu repository"
#      describes this package, not the software that ends up executing.
#
# No third-party APT source is added.

set -euo pipefail

readonly package='steam-installer'

if [[ $EUID -eq 0 ]]; then
    printf '%s\n' 'Run as the graphical desktop user; it will use sudo only for apt.' >&2
    exit 1
fi

if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'ok installed'; then
    printf 'Already installed: %s %s\n' "$package" "$(dpkg-query -W -f='${Version}' "$package")"
    exit 0
fi

if dpkg --print-foreign-architectures | grep -qx 'i386'; then
    printf '%s\n' 'i386 architecture already enabled.'
else
    printf '%s\n' 'Enabling the i386 architecture (required by steam-libs-i386)...'
    sudo dpkg --add-architecture i386
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes "$package"

printf '\nInstalled %s %s\n' "$package" "$(dpkg-query -W -f='${Version}' "$package")"
printf '%s\n' 'First run downloads Valve'"'"'s own client and requires signing in.'
printf '%s\n' 'Use the phone/tablet remote input (Spec 016) for the password and any Steam Guard code.'
