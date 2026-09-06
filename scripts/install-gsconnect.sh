#!/usr/bin/env bash

# Spec 016: install GSConnect, the GNOME Shell implementation of the KDE Connect
# protocol, for phone-based keyboard and pointer input.
#
# Ubuntu repository only. The Plasma `kdeconnect` package is deliberately not
# used: it would pull Qt and KDE libraries onto a GNOME appliance for no benefit.
#
# This installs and enables the extension but deliberately does NOT pair a phone.
# GSConnect stores plugin state per device, so the policy in
# scripts/configure-gsconnect.sh can only be applied once a device exists. Pair,
# then run it immediately.

set -euo pipefail

readonly package='gnome-shell-extension-gsconnect'
readonly extension='gsconnect@andyholmes.github.io'

if [[ $EUID -eq 0 ]]; then
    printf '%s\n' 'Run as the graphical desktop user; it will use sudo only for apt.' >&2
    exit 1
fi

if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'ok installed'; then
    printf 'Already installed: %s %s\n' "$package" \
        "$(dpkg-query -W -f='${Version}' "$package")"
else
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes "$package"
    printf 'Installed %s %s\n' "$package" "$(dpkg-query -W -f='${Version}' "$package")"
fi

# GNOME Shell cannot be restarted in place on Wayland, so a freshly installed
# extension is not visible to the running session until the user logs out and
# back in. Report that rather than failing confusingly.
if ! gnome-extensions list 2>/dev/null | grep -qx "$extension"; then
    printf '\n%s\n' "$extension is installed but not yet visible to this GNOME session."
    printf '%s\n' 'Log out and back in (or reboot), then re-run this script to enable it.'
    exit 0
fi

if gnome-extensions list --enabled 2>/dev/null | grep -qx "$extension"; then
    printf '%s\n' 'Extension already enabled.'
else
    gnome-extensions enable "$extension"
    printf '%s\n' 'Extension enabled.'
fi

printf '\n%s\n' 'Next: pair the phone, then IMMEDIATELY run:'
printf '%s\n' '  scripts/configure-gsconnect.sh --apply    # restrict to remote input'
printf '%s\n' '  scripts/configure-gsconnect.sh --harden   # stop advertising on the LAN'
printf '%s\n' 'The policy cannot be applied before pairing: GSConnect stores plugin state'
printf '%s\n' 'per device, and permissive defaults (file receive, SFTP automount,'
printf '%s\n' 'notification forwarding) are live from the moment a device pairs.'
