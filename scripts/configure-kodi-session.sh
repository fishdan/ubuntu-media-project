#!/usr/bin/env bash

set -euo pipefail

readonly SCHEMA="org.gnome.desktop.session"
readonly KEY="idle-delay"

usage() {
    printf 'Usage: %s --check | --apply | --restore-default\n' "${0##*/}" >&2
    exit 2
}

if [[ $EUID -eq 0 ]]; then
    printf '%s\n' "Run this script as the graphical desktop user, not root." >&2
    exit 1
fi

case "${1:-}" in
    --check)
        [[ $# -eq 1 ]] || usage
        value="$(gsettings get "$SCHEMA" "$KEY")"
        printf 'idle-delay=%s\n' "$value"
        [[ "$value" == "uint32 0" ]]
        ;;
    --apply)
        [[ $# -eq 1 ]] || usage
        gsettings set "$SCHEMA" "$KEY" 'uint32 0'
        printf '%s\n' "Disabled GNOME idle blanking for the media session."
        ;;
    --restore-default)
        [[ $# -eq 1 ]] || usage
        gsettings reset "$SCHEMA" "$KEY"
        printf '%s\n' "Restored the default GNOME idle blanking delay."
        ;;
    *)
        usage
        ;;
esac
