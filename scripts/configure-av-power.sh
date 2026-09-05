#!/usr/bin/env bash
set -euo pipefail

readonly schema=org.gnome.settings-daemon.plugins.power
readonly key=sleep-inactive-ac-type

[[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical desktop user, not root.' >&2; exit 1; }
[[ $# -eq 1 ]] || { printf 'Usage: %s --apply|--check|--restore-baseline\n' "$0" >&2; exit 2; }

case $1 in
    --apply)
        gsettings set "$schema" "$key" 'nothing'
        ;;
    --check)
        value=$(gsettings get "$schema" "$key")
        printf 'AC inactivity action: %s\n' "$value"
        [[ $value == "'nothing'" ]]
        ;;
    --restore-baseline)
        # Recorded Spec 005 baseline; timeout and idle delay are not modified.
        gsettings set "$schema" "$key" 'suspend'
        ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; exit 2 ;;
esac
