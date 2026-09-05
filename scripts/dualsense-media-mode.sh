#!/usr/bin/env bash

set -euo pipefail

readonly device='DualSense Wireless Controller'
readonly preset='media'
# Resolve through symlinks: this script is installed as a symlink in
# ~/.local/bin, and the preset template is found relative to the checkout.
readonly script_dir=$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")" && pwd)
readonly project_dir=$(cd -- "$script_dir/.." && pwd)
readonly template="$project_dir/config/input-remapper/dualsense-media.json.template"
readonly config_root="${XDG_CONFIG_HOME:-$HOME/.config}/input-remapper-2"
readonly preset_dir="$config_root/presets/$device"
readonly preset_path="$preset_dir/$preset.json"
readonly state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/ubuntu-media-project"
readonly state_path="$state_dir/dualsense-media-mode.active"
readonly config_path="$config_root/config.json"
readonly config_version='2.2.0'

usage() {
    printf 'Usage: %s on|on-when-present [seconds]|off|status\n' "${0##*/}" >&2
    exit 2
}

# The daemon refuses every request until a client tells it which config
# directory the session uses, and it will not accept that unless config.json
# exists. Without this, input-remapper-control prints "Starting injection ...
# Done" while the daemon logs "Request to start an injectoin before a user told
# the service about their session" and injects nothing. Autoload is recorded
# here too, so the preset is reapplied when the controller reconnects.
ensure_config() {
    [[ -e $config_path ]] && return 0
    mkdir -p -- "$config_root"
    umask 077
    printf '{\n  "version": "%s",\n  "autoload": {\n    "%s": "%s"\n  }\n}\n' \
        "$config_version" "$device" "$preset" >"$config_path"
    printf 'Created %s\n' "$config_path"
}

# input-remapper's own status is cached intent, and its generic "input-remapper
# mouse"/"keyboard" uinput nodes persist once created. The per-device
# "... forwarded" node is the one that exists only while this controller is
# actually being injected, so it is the honest liveness signal.
injection_is_live() {
    grep -q "N: Name=\"input-remapper $device forwarded\"" /proc/bus/input/devices 2>/dev/null
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

# Spec 015 made the GNOME desktop the appliance's home, so the pointer must be
# available at the desktop rather than only inside the browser. This waits for
# the controller to finish connecting over Bluetooth after login, and exits 0 if
# it never appears, so a missing controller does not fail the login service.
wait_for_controller() {
    local deadline=$((SECONDS + ${1:-60})) name
    while ((SECONDS < deadline)); do
        for name in /sys/class/input/event*/device/name; do
            [[ -r $name ]] || continue
            [[ $(<"$name") == "$device" ]] && return 0
        done
        sleep 2
    done
    return 1
}

case ${1:-} in
    on)
        ensure_config
        install_preset
        input-remapper-control --command start --device "$device" --preset "$preset" --config-dir "$config_root"
        mkdir -p -- "$state_dir"
        : >"$state_path"
        printf '%s\n' 'DualSense desktop media mode: on'
        ;;
    on-when-present)
        if ! wait_for_controller "${2:-60}"; then
            printf '%s\n' 'No DualSense connected; leaving desktop media mode off.' >&2
            printf '%s\n' 'Connect the controller and run: dualsense-media-mode.sh on' >&2
            exit 0
        fi
        ensure_config
        install_preset
        input-remapper-control --command start --device "$device" --preset "$preset" --config-dir "$config_root"
        mkdir -p -- "$state_dir"
        : >"$state_path"
        printf '%s\n' 'DualSense desktop media mode: on'
        ;;
    off)
        input-remapper-control --command stop --device "$device" --config-dir "$config_root"
        rm -f -- "$state_path"
        printf '%s\n' 'DualSense desktop media mode: off (native input available)'
        ;;
    status)
        if injection_is_live; then
            printf '%s\n' 'DualSense desktop media mode: ON (live injection confirmed)'
        elif [[ -e $state_path ]]; then
            printf '%s\n' 'DualSense desktop media mode: REQUESTED BUT NOT INJECTING.' >&2
            printf '%s\n' 'The controller is probably disconnected. Reconnect it and run: dualsense-media-mode.sh on' >&2
            exit 1
        else
            printf '%s\n' 'DualSense desktop media mode: off'
        fi
        ;;
    *) usage ;;
esac
