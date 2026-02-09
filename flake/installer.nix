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
                    sops
                    age
                    jq
                    btrfs-progs
                    dosfstools
                    nvme-cli
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
                      echo "[1/5] Available NVMe drives:"
                      echo ""
                      ${pkgs.util-linux}/bin/lsblk -d -o NAME,SIZE,MODEL,SERIAL | grep -E "nvme|NAME" || true
                      echo ""
                      echo "Disk IDs (by-id):"
                      ls -la /dev/disk/by-id/ | grep nvme | grep -v part || echo "No NVMe drives found by-id"
                      echo ""

                      read -rp "Boot drive (full by-id path, e.g. /dev/disk/by-id/nvme-Samsung_...): " BOOT_DEV
                      read -rp "Projects drive (full by-id path): " PROJECTS_DEV
                      read -rp "Games drive (full by-id path): " GAMES_DEV
                      echo ""

                      # Verify disks exist
                      for dev in "$BOOT_DEV" "$PROJECTS_DEV" "$GAMES_DEV"; do
                        if [ ! -e "$dev" ]; then
                          echo "ERROR: $dev does not exist!"
                          exit 1
                        fi
                      done

                      echo "Disks verified."
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

                      # Create working copy with real disk IDs
                      WORK_DIR=$(mktemp -d)
                      cp -r "$FLAKE" "$WORK_DIR/fracture"
                      chmod -R u+w "$WORK_DIR/fracture"

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
