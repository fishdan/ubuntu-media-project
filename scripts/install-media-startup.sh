#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(CDPATH='' cd -- "$SCRIPT_DIR/.." && pwd)"
readonly USER_BIN_DIR="$HOME/.local/bin"
readonly USER_UNIT_DIR="$HOME/.config/systemd/user"

if [[ $EUID -eq 0 ]]; then
    printf '%s\n' "Run this installer as the graphical desktop user, not root." >&2
    exit 1
fi

install -d -m 0755 "$USER_BIN_DIR" "$USER_UNIT_DIR"
install -m 0755 "$REPO_ROOT/scripts/launch-media-home.sh" "$USER_BIN_DIR/launch-media-home"
install -m 0644 "$REPO_ROOT/config/systemd/user/media-home.service" "$USER_UNIT_DIR/media-home.service"

systemctl --user daemon-reload

# Spec 015 retired the Kodi-first home in favour of the GNOME desktop, so this
# installer no longer enables the unit. The unit and its launcher are still
# installed, because leaving them in place is what makes the retirement
# reversible without a reinstallation. Enablement is now a deliberate act.
printf '%s\n' "Installed media-home.service (left disabled; the desktop is the home)."
printf '%s\n' "Current state: $(systemctl --user is-enabled media-home.service 2>&1)."
printf '%s\n' "To revert to the Kodi-first home: systemctl --user enable --now media-home.service"
