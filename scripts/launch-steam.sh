#!/usr/bin/env bash

# Spec 011: launch Steam into Big Picture with the DualSense handed to Steam.
#
# Spec 008 established that input-remapper's media mode must be OFF before Steam
# starts, or Steam Input sees remapped keyboard and mouse events instead of a
# gamepad. Spec 015 then made that mode ON at login, because the desktop needs a
# pointer. Steam therefore always starts in the wrong state, and asking the owner
# to fix it from the couch would need the keyboard this appliance exists to
# avoid, so the hand-off is automatic.
#
# The off/restore is done by steam-bigpicture.service rather than a trap in this
# script. A trap can be killed before it runs; the unit's ExecStopPost is
# guaranteed to run even if Steam crashes, which is what stops a crash from
# leaving the desktop with no pointer.

set -euo pipefail

case ${1:---start} in
    --start)
        systemctl --user start steam-bigpicture.service
        ;;
    --run)
        [[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical user.' >&2; exit 1; }
        command -v steam >/dev/null || { printf '%s\n' 'Steam is not installed.' >&2; exit 1; }
        # steam:// URL rather than a command-line flag: the flag for Big Picture
        # has been renamed across Steam versions (-bigpicture, then -gamepadui),
        # while this URL has remained stable.
        exec steam steam://open/bigpicture
        ;;
    *) printf 'Usage: %s [--start|--run]\n' "$0" >&2; exit 2 ;;
esac
