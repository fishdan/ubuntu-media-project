#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    printf '%s\n' "Run this installer as root." >&2
    exit 1
fi

if ! apt-cache show kodi >/dev/null 2>&1; then
    printf '%s\n' "Kodi is not available from the configured Ubuntu repositories." >&2
    exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install --yes \
    kodi \
    kodi-eventclients-kodi-send

installed_version="$(dpkg-query -W -f='${Version}' kodi)"
candidate_version="$(apt-cache policy kodi | awk '/Candidate:/ { print $2; exit }')"

printf 'Installed Kodi version: %s\n' "$installed_version"
if [[ "$installed_version" != "$candidate_version" ]]; then
    printf 'Warning: installed version differs from repository candidate: %s\n' "$candidate_version" >&2
fi
