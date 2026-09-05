#!/usr/bin/env bash

# Spec 015: return to the desktop from whatever is running.
#
# Bound to a GNOME custom shortcut rather than relying on the focused window
# honouring a close key: Firefox's kiosk mode has no window controls and does not
# exit on Escape, and Alt+F4 did not return the appliance to the desktop when
# tested from the controller. A compositor-level shortcut running this script
# cannot be swallowed by the focused application.

set -euo pipefail

# Units that present a fullscreen application. Stopping the unit stops the
# application, because each is Type=exec on the application process itself.
readonly units=(
    zuzz-media.service
)

# Logged so that "the button did nothing" can be diagnosed: if this line is in
# the journal the shortcut fired and the fault is downstream; if it is absent the
# key never reached GNOME.
logger -t return-home 'return-home invoked'

stopped=0
for unit in "${units[@]}"; do
    if systemctl --user is-active --quiet "$unit"; then
        systemctl --user stop "$unit"
        printf 'Stopped %s\n' "$unit"
        stopped=1
    fi
done

if [[ $stopped -eq 0 ]]; then
    printf '%s\n' 'Nothing to close; already at the desktop.'
fi
