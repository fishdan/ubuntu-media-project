#!/usr/bin/env bash
# Install the read-only network media share on the APPLIANCE (orpheus).
#
# Mounts nathan's /data/media at /media_remote using a systemd automount, so an
# unavailable media server can never block boot or graphical login. The server
# side is configured separately by scripts/configure-media-server.sh.
#
#   bash scripts/install-network-media.sh            # install / refresh
#   bash scripts/install-network-media.sh --revert   # remove
#
# Idempotent. Safe to re-run.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UNIT_SRC="$REPO_ROOT/config/systemd/system"
UNIT_DST="/etc/systemd/system"
MOUNT_POINT="/media_remote"
MOUNT_UNIT="media_remote.mount"
AUTO_UNIT="media_remote.automount"
EXPECTED_USER="dfish"

log()  { printf '%s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "Run as $EXPECTED_USER with sudo available, not as root."
[ "$(id -un)" = "$EXPECTED_USER" ] || die "Expected to run as $EXPECTED_USER, got $(id -un)."
command -v sudo >/dev/null || die "sudo is required."

revert() {
  log "== reverting =="
  sudo systemctl disable --now "$AUTO_UNIT" 2>/dev/null || true
  # Unmount only if actually mounted; never force.
  if findmnt -rn "$MOUNT_POINT" >/dev/null 2>&1; then
    sudo systemctl stop "$MOUNT_UNIT" 2>/dev/null || sudo umount "$MOUNT_POINT" || \
      die "$MOUNT_POINT is busy. Close anything using it and re-run."
    log "   unmounted $MOUNT_POINT"
  fi
  for u in "$AUTO_UNIT" "$MOUNT_UNIT"; do
    [ -e "$UNIT_DST/$u" ] && { sudo rm -f "$UNIT_DST/$u"; log "   removed $u"; }
  done
  # Shortcuts, so a revert does not leave launchers pointing at a dead path.
  rm -f "$HOME/.local/share/applications/media-remote.desktop" "$HOME/Desktop/media-remote.desktop"
  if [ -f "$HOME/.config/gtk-3.0/bookmarks" ]; then
    grep -v "^file:///media_remote" "$HOME/.config/gtk-3.0/bookmarks" > "$HOME/.config/gtk-3.0/bookmarks.tmp" 2>/dev/null || true
    mv "$HOME/.config/gtk-3.0/bookmarks.tmp" "$HOME/.config/gtk-3.0/bookmarks"
  fi
  if command -v gsettings >/dev/null; then
    cur="$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "@as []")"
    new="$(printf '%s' "$cur" | sed "s/, *'media-remote.desktop'//; s/'media-remote.desktop', *//; s/\['media-remote.desktop'\]/@as []/")"
    gsettings set org.gnome.shell favorite-apps "$new" 2>/dev/null || true
  fi
  log "   removed shortcuts (bookmark, desktop icon, dock favourite)"
  sudo systemctl daemon-reload
  # Leave the empty directory and nfs-common in place; removing the package could
  # affect anything else using NFS, and an empty directory is harmless.
  if [ -d "$MOUNT_POINT" ] && [ -z "$(ls -A "$MOUNT_POINT" 2>/dev/null)" ]; then
    sudo rmdir "$MOUNT_POINT" && log "   removed empty $MOUNT_POINT"
  fi
  log "Reverted. nfs-common was left installed deliberately."
  exit 0
}

[ "${1:-}" = "--revert" ] && revert
[ -n "${1:-}" ] && die "Unknown argument: $1 (expected --revert or nothing)"

log "== 1. nfs-common =="
if dpkg-query -W -f='${Status}' nfs-common 2>/dev/null | grep -q "install ok installed"; then
  log "   already installed"
else
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nfs-common
  log "   installed"
fi

log "== 2. mount point =="
if [ -d "$MOUNT_POINT" ]; then
  log "   $MOUNT_POINT exists"
else
  sudo mkdir -p "$MOUNT_POINT"
  log "   created $MOUNT_POINT"
fi
# Must stay empty and root-owned: it is a mount point, not storage. A stray file
# here would be invisible once the share mounts over it.
#
# Only enforce this when nothing is mounted over it. With the read-only share
# mounted, chown/chmod necessarily fail with EROFS -- they would be acting on the
# server's directory, not the local mount point -- and under 'set -e' that made
# this script abort on every re-run once the share was in use.
if findmnt -rn "$MOUNT_POINT" >/dev/null 2>&1; then
  log "   mounted; leaving local mount-point permissions alone"
else
  sudo chown root:root "$MOUNT_POINT"
  sudo chmod 0755 "$MOUNT_POINT"
fi

log "== 3. units =="
for u in "$MOUNT_UNIT" "$AUTO_UNIT"; do
  [ -f "$UNIT_SRC/$u" ] || die "Missing tracked unit: $UNIT_SRC/$u"
  if sudo cmp -s "$UNIT_SRC/$u" "$UNIT_DST/$u" 2>/dev/null; then
    log "   $u unchanged"
  else
    sudo install -m 0644 -o root -g root "$UNIT_SRC/$u" "$UNIT_DST/$u"
    log "   deployed $u"
  fi
done
sudo systemctl daemon-reload

log "== 4. enable the automount (never the mount) =="
sudo systemctl enable --now "$AUTO_UNIT" >/dev/null
log "   $AUTO_UNIT: $(systemctl is-enabled "$AUTO_UNIT") / $(systemctl is-active "$AUTO_UNIT")"
if systemctl is-enabled "$MOUNT_UNIT" 2>/dev/null | grep -q enabled; then
  die "$MOUNT_UNIT is enabled. It must NOT be: that would reintroduce a boot-time dependency on the media server."
fi

log "== 5. shortcuts =="
# Without these the share is only reachable by typing a path into Files, which on
# an appliance meant to run without a keyboard makes it effectively unreachable.
DESKTOP_SRC="$REPO_ROOT/config/applications/media-remote.desktop"
APP_DIR="$HOME/.local/share/applications"
DESKTOP_DIR="$HOME/Desktop"
BOOKMARKS="$HOME/.config/gtk-3.0/bookmarks"

[ -f "$DESKTOP_SRC" ] || die "Missing tracked desktop entry: $DESKTOP_SRC"
mkdir -p "$APP_DIR"
if cmp -s "$DESKTOP_SRC" "$APP_DIR/media-remote.desktop"; then
  log "   application entry unchanged"
else
  install -m 0644 "$DESKTOP_SRC" "$APP_DIR/media-remote.desktop"
  log "   application entry deployed"
fi

# Files sidebar bookmark. Worth the most of the three: it also appears in every
# open/save dialog, not just in Files.
mkdir -p "$(dirname "$BOOKMARKS")"
touch "$BOOKMARKS"
if grep -qxF "file:///media_remote Media" "$BOOKMARKS"; then
  log "   sidebar bookmark already present"
else
  # Drop any stale variant first so re-runs cannot accumulate duplicates.
  grep -v "^file:///media_remote" "$BOOKMARKS" > "$BOOKMARKS.tmp" 2>/dev/null || true
  mv "$BOOKMARKS.tmp" "$BOOKMARKS"
  printf 'file:///media_remote Media\n' >> "$BOOKMARKS"
  log "   sidebar bookmark added"
fi

# Desktop icon. The ding@rastersoft.com extension renders these, and GNOME will
# refuse to launch a desktop entry it does not consider trusted, so set that too.
if [ -d "$DESKTOP_DIR" ]; then
  if cmp -s "$DESKTOP_SRC" "$DESKTOP_DIR/media-remote.desktop"; then
    log "   desktop icon unchanged"
  else
    install -m 0755 "$DESKTOP_SRC" "$DESKTOP_DIR/media-remote.desktop"
    log "   desktop icon deployed"
  fi
  # GNOME refuses to launch a desktop entry it does not consider trusted.
  gio set "$DESKTOP_DIR/media-remote.desktop" metadata::trusted true 2>/dev/null || \
    log "   (could not set trusted metadata; may need a right-click Allow Launching)"
else
  log "   no ~/Desktop; skipping desktop icon"
fi

# Dock favourite. Appended to whatever is actually there rather than replacing the
# list, so this cannot quietly undo a favourite the owner removed by hand.
if command -v gsettings >/dev/null; then
  current="$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "@as []")"
  if printf '%s' "$current" | grep -q "media-remote.desktop"; then
    log "   dock favourite already present"
  else
    updated="$(printf '%s' "$current" | sed "s/]$/, 'media-remote.desktop']/; s/^@as \[\]$/['media-remote.desktop']/")"
    gsettings set org.gnome.shell favorite-apps "$updated" 2>/dev/null && \
      log "   dock favourite added" || log "   (could not set dock favourite)"
  fi
fi

log "== 6. verify =="
log "   automount : $(systemctl is-active "$AUTO_UNIT")"
log "   mounted now: $(findmnt -rn "$MOUNT_POINT" >/dev/null 2>&1 && echo yes || echo 'no (correct - mounts on access)')"
log "Done. Browse $MOUNT_POINT to trigger the mount."
