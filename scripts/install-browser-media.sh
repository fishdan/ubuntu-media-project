#!/usr/bin/env bash
set -euo pipefail
readonly repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
[[ $EUID -ne 0 ]] || { printf '%s\n' 'Run as the graphical user.' >&2; exit 1; }
command -v firefox >/dev/null
install -d "$HOME/.local/bin" "$HOME/.config/systemd/user" "$HOME/.local/share/applications"
target="$HOME/.local/bin/launch-zuzz"
if [[ -e $target && ! -L $target ]]; then
    printf 'Refusing to replace regular file: %s\n' "$target" >&2
    exit 1
fi
ln -sfn -- "$repo/scripts/launch-zuzz.sh" "$target"
install -m 0644 "$repo/config/systemd/user/zuzz-media.service" "$HOME/.config/systemd/user/zuzz-media.service"
install -m 0644 "$repo/config/applications/zuzz.desktop" "$HOME/.local/share/applications/zuzz.desktop"
systemctl --user daemon-reload
printf '%s\n' 'Installed Zuzz launcher. Keep this checkout in place. Launch with ~/.local/bin/launch-zuzz.'
