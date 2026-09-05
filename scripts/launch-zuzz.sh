#!/usr/bin/env bash
set -euo pipefail
readonly script_dir=$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")
# Snap-confined Firefox is denied by AppArmor from creating its profile lock
# files under an arbitrary --profile path, so the profile is addressed by name
# and Firefox stores it wherever its own confinement allows.
readonly profile_name='zuzz-media'
case ${1:---start} in
    --start)
        systemctl --user start zuzz-media.service
        ;;
    --restore)
        result=0
        "$script_dir/dualsense-media-mode.sh" off || result=$?
        systemctl --user start media-home.service || result=$?
        exit "$result"
        ;;
    --run)
        [[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical user.' >&2; exit 1; }
        command -v firefox >/dev/null
        umask 077
        profiles_ini=$(find "$HOME" -maxdepth 6 -path '*/.mozilla/firefox/profiles.ini' -print -quit 2>/dev/null || true)
        if [[ -z $profiles_ini ]] || ! grep -qx "Name=$profile_name" "$profiles_ini"; then
            firefox --no-remote -CreateProfile "$profile_name" >/dev/null 2>&1
        fi
        systemctl --user stop media-home.service
        for name in /sys/class/input/event*/device/name; do
            [[ -r $name ]] || continue
            if [[ $(<"$name") == 'DualSense Wireless Controller' ]]; then
                "$script_dir/dualsense-media-mode.sh" on
                break
            fi
        done
        export MOZ_ENABLE_WAYLAND=1
        exec firefox --no-remote -P "$profile_name" --kiosk https://zuzz.tv
        ;;
    *) printf 'Usage: %s [--start|--run|--restore]\n' "$0" >&2; exit 2 ;;
esac
