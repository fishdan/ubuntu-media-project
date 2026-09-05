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

# schema <sep> key <sep> desired value.
# No Steam entry: steam.desktop does not exist until Spec 011 installs it, and a
# favourite pointing at a missing desktop file renders as a blank tile.
readonly settings=(
    "org.gnome.desktop.interface${sep}text-scaling-factor${sep}1.5"
    "org.gnome.desktop.interface${sep}cursor-size${sep}48"
    "org.gnome.shell${sep}favorite-apps${sep}['zuzz.desktop', 'firefox_firefox.desktop', 'kodi.desktop']"
)

usage() {
    printf 'Usage: %s --apply|--revert|--status\n' "${0##*/}" >&2
    exit 2
}

require_user_session() {
    [[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical desktop user, not root.' >&2; exit 1; }
    command -v gsettings >/dev/null || { printf '%s\n' 'gsettings is not available.' >&2; exit 1; }
}

capture_baseline() {
    if [[ -e $baseline_path ]]; then
        printf 'Keeping the existing baseline: %s\n' "$baseline_path"
        return 0
    fi
    mkdir -p -- "$state_dir"
    local entry schema key current
    : >"$baseline_path"
    for entry in "${settings[@]}"; do
        IFS="$sep" read -r schema key _ <<<"$entry"
        current=$(gsettings get "$schema" "$key")
        printf '%s%s%s%s%s\n' "$schema" "$sep" "$key" "$sep" "$current" >>"$baseline_path"
    done
    chmod 0600 -- "$baseline_path"
    printf 'Captured rollback baseline: %s\n' "$baseline_path"
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
}

case ${1:-} in
    --apply)
        require_user_session
        capture_baseline
        apply_settings
        printf '%s\n' 'Desktop home configured. Revert with: configure-desktop-home.sh --revert'
        ;;
    --revert)
        require_user_session
        revert_settings
        ;;
    --status)
        require_user_session
        show_status
        ;;
    *) usage ;;
esac
