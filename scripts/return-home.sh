#!/usr/bin/env bash

# Spec 015, extended by Spec 011: return to the desktop from whatever is running.
#
# Bound to a GNOME custom shortcut (the PS button emits KEY_F14 / XF86Launch5)
# rather than relying on the focused window honouring a close key: Firefox's
# kiosk mode has no window controls and ignores Escape, and Alt+F4 did not return
# the appliance to the desktop when tested from the controller. A
# compositor-level shortcut running this script cannot be swallowed by the
# focused application.

set -euo pipefail

# Applications launched as managed systemd units. Each is Type=exec on the
# application process, so stopping the unit stops the application.
readonly -a units=(
    zuzz-media.service
    steam-bigpicture.service
)

# Applications launched from a desktop entry. GNOME starts these in transient
# scopes such as `app-gnome-brave\x2dbrowser-6048.scope`, which are NOT units we
# can name in advance, so they are matched by application id at run time.
#
# This is an explicit allowlist on purpose. Background helpers like
# update-notifier and evolution-alarm-notify also run as app scopes, and stopping
# every app scope would kill them too.
readonly -a scope_apps=(
    steam
    brave-browser
    firefox
)

# Brave re-executes and registers a second scope under its Chromium identity, so
# closing only the launcher scope would leave the browser running.
readonly -a scope_literals=(
    'org.chromium.Chromium'
)

logger -t return-home 'return-home invoked'

stopped=0

for unit in "${units[@]}"; do
    if systemctl --user is-active --quiet "$unit"; then
        systemctl --user stop "$unit"
        printf 'Stopped %s\n' "$unit"
        stopped=1
    fi
done

# Collect matching transient scopes, then stop them.
scopes=$(systemctl --user list-units --type=scope --no-legend --plain 2>/dev/null | awk '{print $1}' || true)

match_and_stop() {
    local needle="$1" scope
    while read -r scope; do
        [[ -n $scope ]] || continue
        systemctl --user stop "$scope" 2>/dev/null \
            && { printf 'Stopped %s\n' "$scope"; stopped=1; } \
            || printf 'Could not stop %s\n' "$scope" >&2
    done < <(printf '%s\n' "$scopes" | grep -F -- "$needle" || true)
}

for app in "${scope_apps[@]}"; do
    match_and_stop "-$(systemd-escape -- "$app")-"
done

for literal in "${scope_literals[@]}"; do
    match_and_stop "-$literal-"
done

if [[ $stopped -eq 0 ]]; then
    printf '%s\n' 'Nothing to close; already at the desktop.'
fi
