#!/usr/bin/env bash

set -euo pipefail

readonly controller_name='DualSense Wireless Controller'

section() {
    printf '\n%s\n' "$1"
}

section 'Packages'
for package in evtest input-remapper joystick kodi-peripheral-joystick; do
    dpkg-query -W -f='${Package}\t${Version}\n' "$package" 2>/dev/null || \
        printf '%s\t%s\n' "$package" 'not installed'
done

section 'Kernel driver'
if modinfo hid-playstation >/dev/null 2>&1; then
    printf 'hid_playstation available: yes\n'
else
    printf 'hid_playstation available: no\n'
fi

if grep -q '^hid_playstation ' /proc/modules; then
    printf 'hid_playstation loaded: yes\n'
else
    printf 'hid_playstation loaded: no\n'
fi

section 'Input devices'
found=0
for event_path in /sys/class/input/event*; do
    [[ -r "$event_path/device/name" ]] || continue
    name=$(<"$event_path/device/name")
    [[ $name == *DualSense* ]] || continue
    found=1
    printf '%s\t%s\n' "${event_path##*/}" "$name"
done
(( found == 1 )) || printf 'none\n'

section 'Joystick interfaces'
if compgen -G '/dev/input/js*' >/dev/null; then
    for joystick in /dev/input/js*; do
        if command -v jstest >/dev/null 2>&1; then
            # --normal prints the device name and capability counts before its
            # continuous event loop. A short timeout keeps this report bounded.
            timeout 0.3s jstest --normal "$joystick" 2>/dev/null | head -n 2 || true
        else
            printf '%s\n' "$joystick"
        fi
    done
else
    printf 'none\n'
fi

section 'Battery'
battery_found=0
for supply in /sys/class/power_supply/*; do
    [[ -d $supply ]] || continue
    supply_name=${supply##*/}
    [[ $supply_name == *sony_controller_battery* ]] || continue
    battery_found=1
    printf '%s' 'controller battery'
    [[ -r $supply/capacity ]] && printf '\tcapacity=%s%%' "$(<"$supply/capacity")"
    [[ -r $supply/status ]] && printf '\tstatus=%s' "$(<"$supply/status")"
    printf '\n'
done
(( battery_found == 1 )) || printf 'not exposed by the current connection\n'

section 'Kodi joystick support'
if dpkg-query -W -f='${Status}' kodi-peripheral-joystick 2>/dev/null | grep -q 'install ok installed'; then
    printf 'installed: yes\n'
else
    printf 'installed: no\n'
fi

section 'Privacy'
printf '%s\n' 'Bluetooth addresses and unique device identifiers are intentionally omitted.'

