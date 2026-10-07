#!/usr/bin/env bash
# Configure the NFS export on the MEDIA SERVER (nathan, 192.168.1.163), not on the appliance.
#
# This repository otherwise describes the appliance only. This script is the one
# exception, added on 2026-10-07 when the owner asked for the server to be set up
# too, and it is tracked so the server side is reproducible rather than a
# remembered sequence of commands.
#
# Run it ON the server:
#   ssh dfish@192.168.1.163 'bash -s' < scripts/configure-media-server.sh
#
# Idempotent. Safe to re-run.
set -euo pipefail

MEDIA_DIR="${MEDIA_DIR:-/data/media}"
ALLOW_CIDR="${ALLOW_CIDR:-192.168.1.0/24}"
EXPORT_OPTS="ro,sync,no_subtree_check,root_squash"
OWNER="${OWNER:-dfish}"

log() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -ne 0 ] || die "Run as a normal user with sudo, not as root."
command -v sudo >/dev/null || die "sudo is required."
id "$OWNER" >/dev/null 2>&1 || die "User '$OWNER' does not exist on this server."

# The media directory must live on the data disk, which must already be mounted.
parent="$(dirname "$MEDIA_DIR")"
mountpoint -q "$parent" || die "$parent is not a mount point. Refusing to create media storage on the root filesystem by accident."

log "== 1. nfs-kernel-server =="
if dpkg-query -W -f='${Status}' nfs-kernel-server 2>/dev/null | grep -q "install ok installed"; then
  log "   already installed"
else
  sudo apt-get update -qq
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nfs-kernel-server
  log "   installed"
fi

log "== 2. media directory =="
if [ -d "$MEDIA_DIR" ]; then
  log "   $MEDIA_DIR exists"
else
  sudo mkdir -p "$MEDIA_DIR"
  log "   created $MEDIA_DIR"
fi
# Owned by the media user so files can be managed locally; the export is read-only
# so the appliance cannot write regardless of these permissions.
sudo chown "$OWNER:$OWNER" "$MEDIA_DIR"
sudo chmod 0755 "$MEDIA_DIR"

log "== 3. export =="
line="$MEDIA_DIR $ALLOW_CIDR($EXPORT_OPTS)"
sudo touch /etc/exports
if [ ! -f /etc/exports.before-media-appliance ]; then
  sudo cp -a /etc/exports /etc/exports.before-media-appliance
  log "   recovery copy: /etc/exports.before-media-appliance"
fi
if grep -qF "$line" /etc/exports; then
  log "   export already present"
elif grep -qE "^[[:space:]]*${MEDIA_DIR}[[:space:]]" /etc/exports; then
  die "$MEDIA_DIR is already exported with different options. Refusing to change it; edit /etc/exports by hand."
else
  printf '%s\n' "$line" | sudo tee -a /etc/exports >/dev/null
  log "   added: $line"
fi

log "== 4. apply =="
sudo exportfs -ra
sudo systemctl enable --now nfs-server >/dev/null 2>&1 || sudo systemctl restart nfs-server

log "== 5. verify =="
sudo exportfs -s
systemctl is-active nfs-server
log "Done. Export is READ-ONLY to $ALLOW_CIDR."
