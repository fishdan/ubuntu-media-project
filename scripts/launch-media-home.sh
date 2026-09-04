#!/usr/bin/env bash

set -euo pipefail

if ! command -v kodi >/dev/null 2>&1; then
    printf '%s\n' "Media home is staged but Kodi is not installed; leaving the GNOME desktop available."
    exit 0
fi

printf '%s\n' "Starting Kodi media home."
exec kodi -fs
