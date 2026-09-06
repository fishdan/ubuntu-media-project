#!/usr/bin/env bash

# Spec 016: restrict GSConnect to remote input only.
#
# GSConnect keeps plugin state PER DEVICE, and a device only exists once it is
# paired, so this cannot be applied in advance. Run it immediately after pairing,
# before using the phone for anything else. The gap matters because several
# defaults are permissive: Share.receive-files, SFTP.automount and
# Notification.send-notifications are all true out of the box.
#
# The mechanism is the Device schema's `disabled-plugins` list. The per-plugin
# schemas have no `enabled` key; setting one silently does nothing.

set -euo pipefail

readonly base='org.gnome.Shell.Extensions.GSConnect'
readonly root_path='/org/gnome/shell/extensions/gsconnect'

# The only plugin this feature needs: remote pointer and keyboard input.
readonly keep='mousepad'

# Everything else GSConnect ships. Disabled by name in `disabled-plugins`.
readonly -a disable=(
    battery clipboard contacts findmyphone mpris notification ping
    presenter runcommand sftp share sms systemvolume telephony
)

usage() { printf 'Usage: %s --apply|--status|--harden\n' "${0##*/}" >&2; exit 2; }

[[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical desktop user, not root.' >&2; exit 1; }
command -v gsettings >/dev/null || { printf '%s\n' 'gsettings is unavailable.' >&2; exit 1; }

paired_devices() { dconf list "$root_path/device/" 2>/dev/null | sed 's:/$::' || true; }

as_gvariant_list() {
    local out='[' first=1 item
    for item in "$@"; do
        [[ $first -eq 1 ]] && first=0 || out+=', '
        out+="'$item'"
    done
    printf '%s]' "$out"
}

apply_to_device() {
    local id="$1" path="$root_path/device/$id/"
    printf '  device %s\n' "$id"

    gsettings set "$base.Device:$path" disabled-plugins "$(as_gvariant_list "${disable[@]}")"
    printf '    disabled: %s\n' "${disable[*]}"
    printf '    kept:     %s\n' "$keep"

    # Defence in depth. Even with a plugin disabled, leave its own switches off so
    # that re-enabling one by accident does not immediately start moving data.
    gsettings set "$base.Plugin.Share:${path}plugin/share/"          receive-files      false 2>/dev/null || true
    gsettings set "$base.Plugin.SFTP:${path}plugin/sftp/"            automount          false 2>/dev/null || true
    gsettings set "$base.Plugin.Notification:${path}plugin/notification/" send-notifications false 2>/dev/null || true
    gsettings set "$base.Plugin.Clipboard:${path}plugin/clipboard/"  receive-content    false 2>/dev/null || true
    gsettings set "$base.Plugin.Clipboard:${path}plugin/clipboard/"  send-content       false 2>/dev/null || true
    gsettings set "$base.Plugin.Contacts:${path}plugin/contacts/"    contacts-source    false 2>/dev/null || true
    gsettings set "$base.Plugin.MPRIS:${path}plugin/mpris/"          share-players      false 2>/dev/null || true
    gsettings set "$base.Plugin.SystemVolume:${path}plugin/systemvolume/" share-sinks   false 2>/dev/null || true
    printf '    cleared permissive per-plugin defaults\n'

    # Trim the phone's action menu to match what is actually enabled.
    gsettings set "$base.Device:$path" menu-actions "['keyboard']" 2>/dev/null || true
}

case ${1:-} in
    --apply)
        devices=$(paired_devices)
        if [[ -z $devices ]]; then
            printf '%s\n' 'No paired devices yet.'
            printf '%s\n' 'Pair the phone, then run this immediately - the defaults are permissive.'
            exit 0
        fi
        while read -r id; do [[ -n $id ]] && apply_to_device "$id"; done <<<"$devices"
        printf '\n%s\n' 'Policy applied: remote input only.'
        ;;
    --harden)
        # Stop advertising on the LAN once pairing is done. The appliance has no
        # firewall, so not announcing itself is the cheapest available reduction
        # in exposure. Set discoverable back to true to pair another device.
        gsettings set "$base" discoverable false
        printf '%s\n' 'GSConnect discovery disabled. Re-enable with:'
        printf '%s\n' "  gsettings set $base discoverable true"
        ;;
    --status)
        printf 'discoverable: %s\n' "$(gsettings get "$base" discoverable 2>/dev/null)"
        devices=$(paired_devices)
        [[ -z $devices ]] && { printf '%s\n' 'No paired devices.'; exit 0; }
        while read -r id; do
            [[ -n $id ]] || continue
            local_path="$root_path/device/$id/"
            printf 'device %s\n' "$id"
            printf '  paired:           %s\n' "$(gsettings get "$base.Device:$local_path" paired 2>/dev/null)"
            printf '  disabled-plugins: %s\n' "$(gsettings get "$base.Device:$local_path" disabled-plugins 2>/dev/null)"
        done <<<"$devices"
        ;;
    *) usage ;;
esac
