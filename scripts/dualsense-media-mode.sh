#!/usr/bin/env bash

set -euo pipefail

readonly device='DualSense Wireless Controller'
readonly preset='media'
readonly script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
readonly project_dir=$(cd -- "$script_dir/.." && pwd)
readonly template="$project_dir/config/input-remapper/dualsense-media.json.template"
readonly config_root="${XDG_CONFIG_HOME:-$HOME/.config}/input-remapper-2"
readonly preset_dir="$config_root/presets/$device"
readonly preset_path="$preset_dir/$preset.json"
readonly state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/ubuntu-media-project"
readonly state_path="$state_dir/dualsense-media-mode.active"

usage() {
    printf 'Usage: %s on|off|status\n' "${0##*/}" >&2
    exit 2
}

install_preset() {
    [[ -r $template ]] || { printf 'Missing preset template: %s\n' "$template" >&2; exit 1; }
    mkdir -p -- "$preset_dir"
    if [[ ! -e $preset_path ]]; then
        install -m 0600 -- "$template" "$preset_path"
    elif ! cmp -s -- "$template" "$preset_path"; then
        printf 'Refusing to overwrite modified preset: %s\n' "$preset_path" >&2
        printf '%s\n' 'Reconcile it with the tracked template, then retry.' >&2
        exit 1
    fi
}

case ${1:-} in
    on)
        install_preset
        input-remapper-control --command start --device "$device" --preset "$preset"
        mkdir -p -- "$state_dir"
        : >"$state_path"
        printf '%s\n' 'DualSense desktop media mode: on'
        ;;
    off)
        input-remapper-control --command stop --device "$device"
        rm -f -- "$state_path"
        printf '%s\n' 'DualSense desktop media mode: off (native input available)'
        ;;
    status)
        if [[ -e $state_path ]] && systemctl is-active --quiet input-remapper; then
            printf '%s\n' 'DualSense desktop media mode: last requested on (live injection not verified)'
        else
            printf '%s\n' 'DualSense desktop media mode: no active request recorded (live injection not verified)'
        fi
        ;;
    *) usage ;;
esac
