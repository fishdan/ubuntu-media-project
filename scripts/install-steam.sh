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

readonly repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
readonly bin_dir="$HOME/.local/bin"
readonly unit_dir="$HOME/.config/systemd/user"
readonly app_dir="$HOME/.local/share/applications"

deploy_launcher() {
    install -d -m 0755 "$bin_dir" "$unit_dir" "$app_dir"
    local target="$bin_dir/launch-steam"
    if [[ -e $target && ! -L $target ]]; then
        printf 'Refusing to replace regular file: %s\n' "$target" >&2
        exit 1
    fi
    ln -sfn -- "$repo/scripts/launch-steam.sh" "$target"
    install -m 0644 "$repo/config/systemd/user/steam-bigpicture.service" "$unit_dir/steam-bigpicture.service"
    install -m 0644 "$repo/config/applications/steam-bigpicture.desktop" "$app_dir/steam-bigpicture.desktop"
    systemctl --user daemon-reload
    printf '%s\n' 'Deployed launch-steam, steam-bigpicture.service and its desktop entry.'
}

if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'ok installed'; then
    printf 'Already installed: %s %s\n' "$package" "$(dpkg-query -W -f='${Version}' "$package")"
    deploy_launcher
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

deploy_launcher

printf '%s\n' 'First run downloads Valve'"'"'s own client and requires signing in.'
printf '%s\n' 'Use the phone/tablet remote input (Spec 016) for the password and any Steam Guard code.'
