#!/usr/bin/env bash

# Spec 015: install the desktop-first home.
#
# Run as the graphical desktop user. This is idempotent and safe to re-run: it
# never enables media-home.service, so it will not undo the Kodi retirement, and
# configure-desktop-home.sh keeps its original rollback baseline across runs.

set -euo pipefail

readonly repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
readonly bin_dir="$HOME/.local/bin"
readonly unit_dir="$HOME/.config/systemd/user"

[[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical desktop user, not root.' >&2; exit 1; }

install -d -m 0755 "$bin_dir" "$unit_dir"

link_script() {
    local source="$1" target="$bin_dir/$2"
    if [[ -e $target && ! -L $target ]]; then
        printf 'Refusing to replace regular file: %s\n' "$target" >&2
        exit 1
    fi
    ln -sfn -- "$source" "$target"
}

link_script "$repo/scripts/dualsense-media-mode.sh" dualsense-media-mode
link_script "$repo/scripts/configure-desktop-home.sh" configure-desktop-home

install -m 0644 "$repo/config/systemd/user/dualsense-desktop-input.service" \
    "$unit_dir/dualsense-desktop-input.service"

systemctl --user daemon-reload
systemctl --user enable --now dualsense-desktop-input.service

"$repo/scripts/configure-desktop-home.sh" --apply

printf '\n%s\n' 'Desktop-first home installed.'
printf '%s\n' "  pointer mode:  $(systemctl --user is-active dualsense-desktop-input.service)"
printf '%s\n' "  media-home:    $(systemctl --user is-enabled media-home.service 2>&1) (expected: disabled)"
printf '%s\n' 'Revert with: docs/desktop-home.md'
