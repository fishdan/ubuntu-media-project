#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo 'Run as the desktop user, not root.' >&2
    exit 1
fi

repo_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
python3 -c 'import dbus' || { echo 'Install python3-dbus first.' >&2; exit 1; }
command -v vlc >/dev/null || { echo 'VLC is required.' >&2; exit 1; }

# Build before replacing the desktop entry. This fails clearly if the share is unavailable.
python3 "$repo_root/scripts/build-bsg-playlist.py"

bin_dir="$HOME/.local/bin/ubuntu-media-project"
unit_dir="$HOME/.config/systemd/user"
app_dir="$HOME/.local/share/applications"
desktop_dir="$HOME/Desktop"
mkdir -p "$bin_dir" "$unit_dir" "$app_dir" "$desktop_dir"
changed=0
if ! cmp -s "$repo_root/scripts/bsg-resume.py" "$bin_dir/bsg-resume"; then
    install -m 755 "$repo_root/scripts/bsg-resume.py" "$bin_dir/bsg-resume"
    changed=1
fi
if ! cmp -s "$repo_root/config/systemd/user/bsg-playback-tracker.service" "$unit_dir/bsg-playback-tracker.service"; then
    install -m 644 "$repo_root/config/systemd/user/bsg-playback-tracker.service" "$unit_dir/bsg-playback-tracker.service"
    changed=1
fi

launcher="$desktop_dir/Battlestar Galactica.desktop"
cat > "$launcher" <<EOF
[Desktop Entry]
Type=Application
Name=Battlestar Galactica
Comment=Resume the BSG watch-order playlist
Exec=/usr/bin/python3 "$bin_dir/bsg-resume" launch
Icon=video-x-generic
Terminal=false
Categories=AudioVideo;Video;Player;
EOF
install -m 644 "$launcher" "$app_dir/bsg-resume.desktop"
chmod +x "$launcher"
gio set "$launcher" metadata::trusted true

old_playlist="$desktop_dir/Battlestar Galactica.xspf"
new_playlist="$HOME/.local/share/ubuntu-media-project/Battlestar Galactica.xspf"
if [[ -f $old_playlist ]]; then
    if cmp -s "$old_playlist" "$new_playlist"; then
        rm -- "$old_playlist"
    else
        echo "Kept modified old playlist: $old_playlist" >&2
    fi
fi

systemctl --user daemon-reload
systemctl --user enable --now bsg-playback-tracker.service
if (( changed )); then
    systemctl --user restart bsg-playback-tracker.service
fi
echo "Installed desktop Resume launcher and playback tracker."
