#!/usr/bin/env bash

set -euo pipefail

readonly GDM_CONFIG="/etc/gdm3/custom.conf"
readonly BACKUP_CONFIG="/etc/gdm3/custom.conf.before-media-appliance"

usage() {
    printf 'Usage: %s --check USER | --apply USER | --disable\n' "${0##*/}" >&2
    exit 2
}

require_root() {
    if [[ $EUID -ne 0 ]]; then
        printf '%s\n' "This operation must run as root." >&2
        exit 1
    fi
}

validate_user() {
    local user="$1"
    local uid

    if [[ "$user" == "root" ]]; then
        printf '%s\n' "Refusing to configure automatic login for root." >&2
        exit 1
    fi
    uid="$(id -u -- "$user" 2>/dev/null)" || {
        printf 'User does not exist: %s\n' "$user" >&2
        exit 1
    }
    if ((uid < 1000)); then
        printf 'Refusing system account with UID %s: %s\n' "$uid" "$user" >&2
        exit 1
    fi
}

read_daemon_value() {
    local key="$1"

    awk -F= -v wanted="$key" '
        /^[[:space:]]*\[daemon\][[:space:]]*$/ { in_daemon=1; next }
        /^[[:space:]]*\[/ { in_daemon=0 }
        in_daemon {
            name=$1
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", name)
            if (name == wanted) {
                value=substr($0, index($0, "=") + 1)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
                print value
                exit
            }
        }
    ' "$GDM_CONFIG"
}

write_daemon_values() {
    local enabled="$1"
    local user="$2"
    local temporary

    temporary="$(mktemp)"
    trap "rm -f -- '$temporary'" EXIT

    awk -v enabled="$enabled" -v user="$user" '
        function emit_missing() {
            if (!seen_enable) print "AutomaticLoginEnable=" enabled
            if (user != "" && !seen_user) print "AutomaticLogin=" user
        }
        /^[[:space:]]*\[daemon\][[:space:]]*$/ {
            in_daemon=1
            saw_daemon=1
            print
            next
        }
        /^[[:space:]]*\[/ {
            if (in_daemon) emit_missing()
            in_daemon=0
            print
            next
        }
        in_daemon && /^[[:space:]]*AutomaticLoginEnable[[:space:]]*=/ {
            if (!seen_enable) print "AutomaticLoginEnable=" enabled
            seen_enable=1
            next
        }
        in_daemon && /^[[:space:]]*AutomaticLogin[[:space:]]*=/ {
            if (user != "" && !seen_user) print "AutomaticLogin=" user
            seen_user=1
            next
        }
        { print }
        END {
            if (in_daemon) emit_missing()
            if (!saw_daemon) {
                print ""
                print "[daemon]"
                print "AutomaticLoginEnable=" enabled
                if (user != "") print "AutomaticLogin=" user
            }
        }
    ' "$GDM_CONFIG" > "$temporary"

    if cmp -s "$GDM_CONFIG" "$temporary"; then
        printf '%s\n' "GDM automatic-login configuration already matches."
        return
    fi

    if [[ ! -e "$BACKUP_CONFIG" ]]; then
        install -m 0644 "$GDM_CONFIG" "$BACKUP_CONFIG"
        printf 'Created recovery backup: %s\n' "$BACKUP_CONFIG"
    fi
    install -m 0644 "$temporary" "$GDM_CONFIG"
    printf 'Updated: %s\n' "$GDM_CONFIG"
}

[[ -r "$GDM_CONFIG" ]] || {
    printf 'GDM configuration is not readable: %s\n' "$GDM_CONFIG" >&2
    exit 1
}

case "${1:-}" in
    --check)
        [[ $# -eq 2 ]] || usage
        validate_user "$2"
        enabled="$(read_daemon_value AutomaticLoginEnable)"
        configured_user="$(read_daemon_value AutomaticLogin)"
        printf 'AutomaticLoginEnable=%s\nAutomaticLogin=%s\n' "$enabled" "$configured_user"
        [[ "$enabled" == "true" && "$configured_user" == "$2" ]]
        ;;
    --apply)
        [[ $# -eq 2 ]] || usage
        require_root
        validate_user "$2"
        write_daemon_values true "$2"
        ;;
    --disable)
        [[ $# -eq 1 ]] || usage
        require_root
        configured_user="$(read_daemon_value AutomaticLogin)"
        write_daemon_values false "$configured_user"
        ;;
    *)
        usage
        ;;
esac
