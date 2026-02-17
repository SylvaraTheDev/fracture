set -euo pipefail

FLAKE="/etc/fracture/flake"
AGE_KEY="/etc/fracture/age-keys.txt"
TARGET_HOST="fracture"

echo "========================================"
echo "  Fracture Installer"
echo "========================================"
echo ""

# --- Step 1: Identify disks ---
echo "[1/5] Detecting NVMe drives..."
echo ""

# Find NVMe drives (not partitions, not eui aliases)
mapfile -t NVME_IDS < <(
  for f in /dev/disk/by-id/nvme-*; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    [[ "$name" == *part[0-9]* ]] && continue
    [[ "$name" == nvme-eui.* ]] && continue
    echo "$name"
  done | sort
)

if [ ${#NVME_IDS[@]} -lt 3 ]; then
  echo "ERROR: Need at least 3 NVMe drives, found ${#NVME_IDS[@]}."
  echo "Check BIOS settings and ensure drives are in NVMe mode (not RAID)."
  exit 1
fi

echo "Available NVMe drives:"
echo ""
for i in "${!NVME_IDS[@]}"; do
  ID="${NVME_IDS[$i]}"
  DEV=$(readlink -f "/dev/disk/by-id/$ID")
  SIZE=$(lsblk -dno SIZE "$DEV" 2>/dev/null || echo "?")
  MODEL=$(lsblk -dno MODEL "$DEV" 2>/dev/null || echo "?")
  echo "  [$((i+1))] $SIZE  $MODEL"
  echo "      $ID"
  echo ""
done

pick_drive() {
  local label=$1
  while true; do
    read -rp "Select $label drive [1-${#NVME_IDS[@]}]: " num
    local idx=$((num - 1))
    if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#NVME_IDS[@]}" ]; then
      PICKED="/dev/disk/by-id/${NVME_IDS[$idx]}"
      return
    fi
    echo "Invalid selection, try again."
  done
}

pick_drive "boot (1TB)"
BOOT_DEV="$PICKED"
pick_drive "projects (1TB)"
PROJECTS_DEV="$PICKED"
pick_drive "games (2TB)"
GAMES_DEV="$PICKED"

# Verify no duplicates
if [ "$BOOT_DEV" = "$PROJECTS_DEV" ] || [ "$BOOT_DEV" = "$GAMES_DEV" ] || [ "$PROJECTS_DEV" = "$GAMES_DEV" ]; then
  echo "ERROR: Each role must use a different drive!"
  exit 1
fi

echo ""
echo "Selected:"
echo "  Boot:     $BOOT_DEV"
echo "  Projects: $PROJECTS_DEV"
echo "  Games:    $GAMES_DEV"
echo ""

# --- Step 2: Partition with disko ---
echo "[2/5] Partitioning disks with disko..."
echo ""
echo "WARNING: This will ERASE the following drives:"
echo "  Boot:     $BOOT_DEV"
echo "  Projects: $PROJECTS_DEV"
echo "  Games:    $GAMES_DEV"
echo ""
read -rp "Type YES to continue: " CONFIRM
if [ "$CONFIRM" != "YES" ]; then
  echo "Aborted."
  exit 1
fi

# Create writable copy (dereferences nix store symlinks)
WORK_DIR=$(mktemp -d)
rsync -rL --no-perms --no-owner --no-group \
  --exclude='.devenv' --exclude='.direnv' \
  "$FLAKE/" "$WORK_DIR/fracture/"

# Patch host.nix with actual disk IDs
sed -i \
  -e "s|/dev/disk/by-id/REPLACE-WITH-BOOT-NVME-ID|$BOOT_DEV|" \
  -e "s|/dev/disk/by-id/REPLACE-WITH-PROJECTS-NVME-ID|$PROJECTS_DEV|" \
  -e "s|/dev/disk/by-id/REPLACE-WITH-GAMES-NVME-ID|$GAMES_DEV|" \
  "$WORK_DIR/fracture/host.nix"

echo "Patched host.nix:"
cat "$WORK_DIR/fracture/host.nix"
echo ""

# Run disko
disko --mode disko --flake "$WORK_DIR/fracture#$TARGET_HOST"

# Create blank snapshots for ephemeral wipe
echo "Creating blank snapshots for ephemeral drives..."
mkdir -p /mnt-snap

mount -t btrfs -o subvolid=5 /dev/disk/by-partlabel/disk-projects-main /mnt-snap
btrfs subvolume snapshot -r /mnt-snap/@projects /mnt-snap/@projects-blank
umount /mnt-snap

mount -t btrfs -o subvolid=5 /dev/disk/by-partlabel/disk-games-main /mnt-snap
btrfs subvolume snapshot -r /mnt-snap/@games /mnt-snap/@games-blank
umount /mnt-snap

rmdir /mnt-snap
echo "Blank snapshots created."

# --- Step 3: Place age key ---
echo "[3/5] Placing SOPS age keyfile..."
mkdir -p /mnt/persist/etc/sops/age
cp "$AGE_KEY" /mnt/persist/etc/sops/age/keys.txt
chmod 400 /mnt/persist/etc/sops/age/keys.txt
echo "Age key installed."

# --- Step 4: Install NixOS ---
echo "[4/5] Installing NixOS..."
nixos-install --flake "$WORK_DIR/fracture#$TARGET_HOST" --no-root-passwd

# --- Step 5: Cleanup ---
echo "[5/5] Cleaning up..."
rm -rf "$WORK_DIR"

echo ""
echo "========================================"
echo "  Installation complete!"
echo "  Remove the USB and reboot."
echo "========================================"
