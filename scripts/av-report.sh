#!/usr/bin/env bash

set -u
set -o pipefail
shopt -s nullglob

section() {
    printf '\n## %s\n' "$1"
}

print_gsetting() {
    local schema="$1"
    local key="$2"

    printf '%s %s: ' "$schema" "$key"
    if command -v gsettings >/dev/null 2>&1; then
        gsettings get "$schema" "$key" 2>/dev/null || printf '%s\n' "unavailable in this session"
    else
        printf '%s\n' "gsettings unavailable"
    fi
}

section "Session and seat"
printf 'Command session type: %s\n' "${XDG_SESSION_TYPE:-unknown}"
if command -v loginctl >/dev/null 2>&1; then
    loginctl list-sessions --no-legend
    loginctl show-seat seat0 -p ActiveSession -p CanGraphical -p State 2>/dev/null || true
fi

section "NVIDIA GPU"
if command -v nvidia-smi >/dev/null 2>&1; then
    nvidia-smi --query-gpu=name,driver_version,memory.total,display_active,display_mode --format=csv,noheader
else
    printf '%s\n' "nvidia-smi unavailable"
fi

section "DRM connectors"
connectors=(/sys/class/drm/card*-*)
if ((${#connectors[@]} == 0)); then
    printf '%s\n' "No DRM connectors found"
fi
for connector in "${connectors[@]}"; do
    [[ -r "$connector/status" ]] || continue
    printf '\nConnector: %s\n' "${connector##*/}"
    printf 'Status: '
    cat "$connector/status"
    if [[ -r "$connector/enabled" ]]; then
        printf 'Enabled: '
        cat "$connector/enabled"
    fi
    if [[ -s "$connector/modes" ]]; then
        printf '%s\n' "Advertised modes:"
        sort -u "$connector/modes" | sed 's/^/  /'
    else
        printf '%s\n' "Advertised modes: none"
    fi
    if [[ -s "$connector/edid" ]]; then
        if command -v edid-decode >/dev/null 2>&1; then
            printf '%s\n' "EDID summary (serial fields omitted):"
            edid-decode "$connector/edid" 2>/dev/null \
                | sed -n -E '/Manufacturer:|Display Product Name:|Maximum image size:|Native detailed mode:/p' \
                | sed 's/^/  /'
        else
            printf '%s\n' "EDID present; install/use edid-decode for a reviewed identity summary"
        fi
    fi
done

section "ALSA playback hardware"
if [[ -r /proc/asound/cards ]]; then
    cat /proc/asound/cards
else
    printf '%s\n' "ALSA card list unavailable"
fi
if command -v aplay >/dev/null 2>&1; then
    aplay -l 2>/dev/null || true
fi

section "PipeWire audio"
if command -v wpctl >/dev/null 2>&1; then
    wpctl status \
        | sed -E 's/cookie:[0-9]+/cookie:[redacted]/g; s/pid:[0-9]+/pid:[runtime]/g'
else
    printf '%s\n' "wpctl unavailable"
fi
if command -v pactl >/dev/null 2>&1; then
    printf '%s\n' "PulseAudio-compatible cards:"
    pactl list cards short
    printf '%s\n' "PulseAudio-compatible sinks:"
    pactl list sinks short
else
    printf '%s\n' "pactl unavailable"
fi

section "GNOME power settings"
print_gsetting org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type
print_gsetting org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout
print_gsetting org.gnome.desktop.session idle-delay

section "Privacy note"
printf '%s\n' "This report omits raw EDID, display serials, MAC/IP addresses, PipeWire runtime cookies, and credentials."
