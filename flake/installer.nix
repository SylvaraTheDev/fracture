{ inputs, ... }:

{
  perSystem =
    { system, pkgs, ... }:
    let
      installer = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          inputs.disko.nixosModules.disko

          (
            { lib, ... }:
            {
              networking = {
                hostName = "fracture-installer";
                wireless.enable = lib.mkForce false;
                networkmanager.enable = true;
              };

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              environment = {
                # Embed the Fracture flake source
                etc."fracture/flake".source = builtins.path {
                  path = ../.;
                  name = "fracture-flake";
                  filter =
                    path: _type:
                    let
                      base = builtins.baseNameOf path;
                    in
                    !builtins.elem base [
                      ".devenv"
                      ".direnv"
                      ".git"
                      "result"
                    ];
                };

                # Embed the age keyfile
                # Create this file before building: cp ~/.config/sops/age/keys.txt secrets/age-keyfile
                etc."fracture/age-keys.txt" = {
                  source = ../secrets/age-keyfile;
                  mode = "0400";
                };

                systemPackages =
                  (with pkgs; [
                    git
                    rsync
                    sops
                    age
                    jq
                    btrfs-progs
                    dosfstools
                    nvme-cli
                    gptfdisk
                    inputs.disko.packages.${system}.disko
                  ])
                  ++ [
                    (pkgs.writeShellScriptBin "docs" ''
                                      cat <<'DOCS'
                      ========================================
                        Fracture Installation Guide
                      ========================================

                      PREREQUISITES
                      ─────────────
                      - 3 NVMe drives (boot, projects, games)
                      - Internet connection (ethernet recommended)
                      - Age keyfile baked into this ISO at /etc/fracture/age-keys.txt

                      COMMANDS
                      ────────
                      fracture-install    Run the guided installer (recommended)
                      fracture-wipe       Wipe NVMe drives clean before installing
                      docs                Show this guide
                      lsblk               List block devices
                      nmtui               Configure WiFi if needed

                      WHAT THE INSTALLER DOES
                      ───────────────────────
                      Step 1: Identify your 3 NVMe drives by /dev/disk/by-id/ paths
                      Step 2: Partition all drives with disko:
                              - Boot (1TB):     ESP + BTRFS (@persist, @nix, @log, @swap)
                              - Projects (1TB): BTRFS (@projects, @persist-projects) + blank snapshot
                              - Games (2TB):    BTRFS (@games, @persist-games) + blank snapshot
                      Step 3: Place your age keyfile into /persist for SOPS decryption
                      Step 4: Install NixOS from the embedded flake
                      Step 5: Cleanup and prompt to reboot

                      DISK LAYOUT
                      ───────────
                      /              tmpfs 2GB (ephemeral - wiped every reboot)
                      /boot          ESP (vfat)
                      /persist       BTRFS @persist (survives reboots)
                      /nix           BTRFS @nix (nix store)
                      /var/log       BTRFS @log (system logs)
                      /swap          BTRFS @swap (32GB swapfile)
                      /projects      BTRFS @projects (ephemeral - wiped every reboot)
                      /persist-projects  BTRFS @persist-projects (survives reboots)
                      /games         BTRFS @games (ephemeral - wiped every reboot)
                      /persist-games BTRFS @persist-games (survives reboots)

                      EPHEMERAL WIPE
                      ──────────────
                      On every boot, @projects and @games subvolumes are deleted and
                      restored from read-only blank snapshots. Only directories declared
                      in impermanence persistence entries survive reboots.

                      Persisted under /persist-projects:
                        /projects/repos      Git repositories (ghq)
                        /projects/ollama     LLM models
                        /projects/openclaw   AI agent workspace
                        /projects/obsidian   Obsidian vaults
                        /projects/godot      Godot projects

                      Persisted under /persist-games:
                        /games/steam         Steam library
                        /games/lutris        Lutris games
                        /games/heroic        Heroic games
                        /games/prismlauncher Minecraft instances

                      AFTER FIRST BOOT
                      ────────────────
                      - Login via regreet (Wayland, Niri compositor)
                      - Clone repos: ghq get github.com/<owner>/<repo>
                        (repos land in /projects/repos/github.com/<owner>/<repo>)
                      - SSH key for GitHub is auto-provisioned via SOPS
                      - All app state is persisted declaratively per-shard

                      TROUBLESHOOTING
                      ───────────────
                      - No NVMe drives shown?  Check BIOS for NVMe mode (not RAID)
                      - Disko fails?           Verify disk IDs with: ls /dev/disk/by-id/
                      - Boot fails after install?  Check BIOS boot order for the ESP
                      - SOPS errors on boot?   Age key may be missing from /persist
                      ========================================
                      DOCS
                    '')

                    (pkgs.writeShellScriptBin "fracture-wipe" ''
                      set -euo pipefail

                      echo "========================================"
                      echo "  Fracture Drive Wiper"
                      echo "========================================"
                      echo ""

                      # Find NVMe drives (not partitions, not eui aliases)
                      mapfile -t NVME_IDS < <(ls /dev/disk/by-id/ 2>/dev/null | grep '^nvme-' | grep -v 'part[0-9]' | grep -v 'nvme-eui\.' | sort)

                      if [ ''${#NVME_IDS[@]} -eq 0 ]; then
                        echo "No NVMe drives found."
                        exit 1
                      fi

                      echo "Available NVMe drives:"
                      echo ""
                      for i in "''${!NVME_IDS[@]}"; do
                        ID="''${NVME_IDS[$i]}"
                        DEV=$(readlink -f "/dev/disk/by-id/$ID")
                        SIZE=$(${pkgs.util-linux}/bin/lsblk -dno SIZE "$DEV" 2>/dev/null || echo "?")
                        MODEL=$(${pkgs.util-linux}/bin/lsblk -dno MODEL "$DEV" 2>/dev/null || echo "?")
                        echo "  [$((i+1))] $SIZE  $MODEL"
                        echo "      $ID"
                        echo ""
                      done

                      echo "Enter drive numbers to wipe (space-separated), or 'all':"
                      read -rp "> " SELECTION

                      TARGETS=()
                      if [ "$SELECTION" = "all" ]; then
                        TARGETS=("''${NVME_IDS[@]}")
                      else
                        for num in $SELECTION; do
                          idx=$((num - 1))
                          if [ "$idx" -ge 0 ] && [ "$idx" -lt "''${#NVME_IDS[@]}" ]; then
                            TARGETS+=("''${NVME_IDS[$idx]}")
                          else
                            echo "Invalid selection: $num"
                            exit 1
                          fi
                        done
                      fi

                      if [ ''${#TARGETS[@]} -eq 0 ]; then
                        echo "No drives selected."
                        exit 1
                      fi

                      echo ""
                      echo "WARNING: The following drives will be COMPLETELY ERASED:"
                      echo ""
                      for ID in "''${TARGETS[@]}"; do
                        DEV=$(readlink -f "/dev/disk/by-id/$ID")
                        echo "  $ID"
                        echo "    -> $DEV"
                      done
                      echo ""
                      read -rp "Type YES to wipe: " CONFIRM
                      if [ "$CONFIRM" != "YES" ]; then
                        echo "Aborted."
                        exit 1
                      fi

                      for ID in "''${TARGETS[@]}"; do
                        DEV=$(readlink -f "/dev/disk/by-id/$ID")
                        echo ""
                        echo "Wiping $DEV ($ID)..."

                        # Unmount any mounted partitions from this drive
                        for part in $(${pkgs.util-linux}/bin/lsblk -lno NAME "$DEV" 2>/dev/null | tail -n +2 || true); do
                          umount -f "/dev/$part" 2>/dev/null || true
                        done
                        umount -f "$DEV" 2>/dev/null || true

                        # Wipe filesystem signatures on partitions first
                        for part in $(${pkgs.util-linux}/bin/lsblk -lno NAME "$DEV" 2>/dev/null | tail -n +2 || true); do
                          ${pkgs.util-linux}/bin/wipefs -af "/dev/$part" 2>/dev/null || true
                        done

                        # Wipe filesystem signatures on the disk itself
                        ${pkgs.util-linux}/bin/wipefs -af "$DEV"

                        # Destroy GPT and MBR partition tables
                        ${pkgs.gptfdisk}/bin/sgdisk --zap-all "$DEV"

                        # TRIM/discard all SSD cells
                        ${pkgs.util-linux}/bin/blkdiscard "$DEV" 2>/dev/null \
                          && echo "  SSD TRIM complete." \
                          || echo "  (blkdiscard not supported, skipping)"

                        echo "  Wiped."
                      done

                      echo ""
                      echo "All selected drives wiped."
                      echo "Run fracture-install to partition and install."
                    '')

                    (pkgs.writeShellScriptBin "fracture-install" ''
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
                      mapfile -t NVME_IDS < <(ls /dev/disk/by-id/ 2>/dev/null | grep '^nvme-' | grep -v 'part[0-9]' | grep -v 'nvme-eui\.' | sort)

                      if [ ''${#NVME_IDS[@]} -lt 3 ]; then
                        echo "ERROR: Need at least 3 NVMe drives, found ''${#NVME_IDS[@]}."
                        echo "Check BIOS settings and ensure drives are in NVMe mode (not RAID)."
                        exit 1
                      fi

                      echo "Available NVMe drives:"
                      echo ""
                      for i in "''${!NVME_IDS[@]}"; do
                        ID="''${NVME_IDS[$i]}"
                        DEV=$(readlink -f "/dev/disk/by-id/$ID")
                        SIZE=$(${pkgs.util-linux}/bin/lsblk -dno SIZE "$DEV" 2>/dev/null || echo "?")
                        MODEL=$(${pkgs.util-linux}/bin/lsblk -dno MODEL "$DEV" 2>/dev/null || echo "?")
                        echo "  [$((i+1))] $SIZE  $MODEL"
                        echo "      $ID"
                        echo ""
                      done

                      pick_drive() {
                        local label=$1
                        while true; do
                          read -rp "Select $label drive [1-''${#NVME_IDS[@]}]: " num
                          local idx=$((num - 1))
                          if [ "$idx" -ge 0 ] && [ "$idx" -lt "''${#NVME_IDS[@]}" ]; then
                            PICKED="/dev/disk/by-id/''${NVME_IDS[$idx]}"
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
                      ${pkgs.rsync}/bin/rsync -rL --no-perms --no-owner --no-group \
                        --exclude='.devenv' --exclude='.direnv' \
                        "$FLAKE/" "$WORK_DIR/fracture/"

                      # Patch host.nix with actual disk IDs and disable VM mode
                      ${pkgs.gnused}/bin/sed -i \
                        -e "s|/dev/disk/by-id/REPLACE-WITH-BOOT-NVME-ID|$BOOT_DEV|" \
                        -e "s|/dev/disk/by-id/REPLACE-WITH-PROJECTS-NVME-ID|$PROJECTS_DEV|" \
                        -e "s|/dev/disk/by-id/REPLACE-WITH-GAMES-NVME-ID|$GAMES_DEV|" \
                        -e "s|enable = true;|enable = false;|" \
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
                      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /mnt-snap/@projects /mnt-snap/@projects-blank
                      umount /mnt-snap

                      mount -t btrfs -o subvolid=5 /dev/disk/by-partlabel/disk-games-main /mnt-snap
                      ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /mnt-snap/@games /mnt-snap/@games-blank
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
                    '')
                  ];
              };
            }
          )
        ];
      };
    in
    {
      packages.installer-iso = installer.config.system.build.isoImage;
    };
}
