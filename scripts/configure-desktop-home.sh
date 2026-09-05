#!/usr/bin/env bash

# Spec 015: make the GNOME desktop legible from the couch, reversibly.
#
# Every value this script writes is captured first, so --revert restores the
# exact prior state. The capture is written once and never overwritten, which
# is what makes repeated --apply runs safe: the baseline always describes the
# appliance as it was before this feature touched it, not as it was after the
# previous run.

set -euo pipefail

readonly state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/ubuntu-media-project"
readonly baseline_path="$state_dir/desktop-home.baseline"
readonly sep=$'\x1f'

# The return-home shortcut lives on a relocatable schema, so it cannot go in the
# plain schema/key table below and is applied and reverted separately.
readonly keybinding_path='/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/return-home/'
readonly keybinding_schema='org.gnome.settings-daemon.plugins.media-keys.custom-keybinding'
readonly keybinding_key='F13'

# schema <sep> key <sep> desired value.
# No Steam entry: steam.desktop does not exist until Spec 011 installs it, and a
# favourite pointing at a missing desktop file renders as a blank tile.
readonly settings=(
    "org.gnome.desktop.interface${sep}text-scaling-factor${sep}1.5"
    "org.gnome.desktop.interface${sep}cursor-size${sep}48"
    "org.gnome.shell${sep}favorite-apps${sep}['zuzz.desktop', 'firefox_firefox.desktop', 'kodi.desktop']"
    # The dock auto-hides by default, which means hunting for a screen edge with
    # a controller stick from across the room. Pin it open and enlarge the icons.
    "org.gnome.shell.extensions.dash-to-dock${sep}dock-fixed${sep}true"
    "org.gnome.shell.extensions.dash-to-dock${sep}autohide${sep}false"
    "org.gnome.shell.extensions.dash-to-dock${sep}dash-max-icon-size${sep}64"
    "org.gnome.settings-daemon.plugins.media-keys${sep}custom-keybindings${sep}['$keybinding_path']"
)

usage() {
    printf 'Usage: %s --apply|--revert|--status\n' "${0##*/}" >&2
    exit 2
}

require_user_session() {
    [[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical desktop user, not root.' >&2; exit 1; }
    command -v gsettings >/dev/null || { printf '%s\n' 'gsettings is not available.' >&2; exit 1; }
}

# Capture is per key, not per file. A key already in the baseline keeps its
# original value, so repeated --apply runs never overwrite the true pre-feature
# state. A key added to `settings` after the first run still gets captured, which
# a whole-file guard would have silently skipped, leaving it unrevertable.
capture_baseline() {
    mkdir -p -- "$state_dir"
    [[ -e $baseline_path ]] || { : >"$baseline_path"; chmod 0600 -- "$baseline_path"; }
    local entry schema key current
    for entry in "${settings[@]}"; do
        IFS="$sep" read -r schema key _ <<<"$entry"
        if grep -qF "$schema$sep$key$sep" "$baseline_path"; then
            continue
        fi
        current=$(gsettings get "$schema" "$key")
        printf '%s%s%s%s%s\n' "$schema" "$sep" "$key" "$sep" "$current" >>"$baseline_path"
        printf '  captured %s %s = %s\n' "$schema" "$key" "$current"
    done
}

apply_keybinding() {
    local command="$HOME/.local/bin/return-home"
    gsettings set "$keybinding_schema:$keybinding_path" name 'Return to desktop'
    gsettings set "$keybinding_schema:$keybinding_path" command "$command"
    gsettings set "$keybinding_schema:$keybinding_path" binding "$keybinding_key"
    printf '  set return-home shortcut %s = %s\n' "$keybinding_key" "$command"
}

revert_keybinding() {
    gsettings reset-recursively "$keybinding_schema:$keybinding_path" 2>/dev/null || true
    printf '%s\n' '  cleared return-home shortcut'
}

apply_settings() {
    local entry schema key value
    for entry in "${settings[@]}"; do
        IFS="$sep" read -r schema key value <<<"$entry"
        gsettings set "$schema" "$key" "$value"
        printf '  set %s %s = %s\n' "$schema" "$key" "$value"
    done
}

revert_settings() {
    [[ -s $baseline_path ]] || {
        printf 'No baseline to revert to: %s\n' "$baseline_path" >&2
        printf '%s\n' 'Nothing was applied, or the baseline was removed by hand.' >&2
        exit 1
    }
    local schema key value
    while IFS="$sep" read -r schema key value; do
        [[ -n $schema ]] || continue
        gsettings set "$schema" "$key" "$value"
        printf '  restored %s %s = %s\n' "$schema" "$key" "$value"
    done <"$baseline_path"
    rm -f -- "$baseline_path"
    printf '%s\n' 'Reverted to the captured baseline.'
}

show_status() {
    local entry schema key value
    if [[ -e $baseline_path ]]; then
        printf 'Baseline present (settings have been applied): %s\n' "$baseline_path"
    else
        printf '%s\n' 'No baseline present; desktop settings are unmodified by this script.'
    fi
    for entry in "${settings[@]}"; do
        IFS="$sep" read -r schema key value <<<"$entry"
        printf '  %s %s\n    now:     %s\n    desired: %s\n' \
            "$schema" "$key" "$(gsettings get "$schema" "$key")" "$value"
    done
    printf '  return-home shortcut\n    now:     %s -> %s\n' \
        "$(gsettings get "$keybinding_schema:$keybinding_path" binding 2>/dev/null || echo unset)" \
        "$(gsettings get "$keybinding_schema:$keybinding_path" command 2>/dev/null || echo unset)"
}

case ${1:-} in
    --apply)
        require_user_session
        capture_baseline
        apply_settings
        apply_keybinding
        printf '%s\n' 'Desktop home configured. Revert with: configure-desktop-home.sh --revert'
        ;;
    --revert)
        require_user_session
        revert_keybinding
        revert_settings
        ;;
    --status)
        require_user_session
        show_status
        ;;
    *) usage ;;
esac
