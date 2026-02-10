# Fracture - NixOS VM Configuration
# ===================================

hostname := "fracture"

# === Safety Checks ===

# Run all pre-commit hooks (enters devshell automatically)
check:
    @echo "Running safety checks..."
    nix develop .#nix --no-pure-eval --command prek run --all-files

# Run checks without hook installation
check-quick:
    @echo "Running quick checks..."
    nix develop .#nix --no-pure-eval --command sh -c "statix check . && deadnix --fail . && gitleaks detect --source . --redact --verbose"

# Scan for secrets only
secrets:
    nix develop .#nix --no-pure-eval --command gitleaks detect --source . --redact --verbose

# === Build & Run ===

# Build and run VM (graphics + serial console)
run: check
    just clean
    nixos-rebuild build-vm --flake .#{{hostname}}
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -serial mon:stdio -m 4096" ./result/bin/run-{{hostname}}-vm

# Run with graphics only (no terminal)
run-graphics: check
    nixos-rebuild build-vm --flake .#{{hostname}}
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -m 4096" ./result/bin/run-{{hostname}}-vm

# Run with serial console only (no graphics)
run-console: check
    nixos-rebuild build-vm --flake .#{{hostname}}
    QEMU_OPTS="-nographic -serial mon:stdio -m 4096" ./result/bin/run-{{hostname}}-vm

# Dry run verification
verify: check
    nixos-rebuild build --flake .#{{hostname}} --dry-run

# === Unsafe Operations (skip checks) ===

# Build and run WITHOUT safety checks (use carefully)
run-unsafe:
    just clean
    nixos-rebuild build-vm --flake .#{{hostname}}
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -serial mon:stdio -m 4096" ./result/bin/run-{{hostname}}-vm

# Verify WITHOUT safety checks
verify-unsafe:
    nixos-rebuild build --flake .#{{hostname}} --dry-run

# === Installer ===

iso_dir := "result/iso"

# Installer ISO management: build, flash <drive>, delete
iso action *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{action}}" in
      build)
        echo "Building Fracture installer ISO..."
        if [ ! -f secrets/age-keyfile ] || grep -q PLACEHOLDER secrets/age-keyfile 2>/dev/null; then
          echo "ERROR: Place your age key at secrets/age-keyfile first"
          echo "  age-keygen -o secrets/age-keyfile"
          echo "  OR: cp ~/.config/sops/age/keys.txt secrets/age-keyfile"
          exit 1
        fi
        git add -f secrets/age-keyfile
        cleanup() { git reset secrets/age-keyfile 2>/dev/null; }
        trap cleanup EXIT
        nix build .#installer-iso --no-pure-eval
        ISO=$(find {{iso_dir}} -name '*.iso' 2>/dev/null | head -1)
        echo ""
        echo "ISO built: $ISO"
        echo "Size: $(du -h "$ISO" | cut -f1)"
        ;;
      flash)
        DRIVE="{{args}}"
        if [ -z "$DRIVE" ]; then
          echo "Usage: just iso flash /dev/sdX"
          echo ""
          echo "Available drives:"
          lsblk -d -o NAME,SIZE,MODEL,TRAN | grep -E "usb|NAME" || lsblk -d -o NAME,SIZE,MODEL
          exit 1
        fi
        ISO=$(find {{iso_dir}} -name '*.iso' 2>/dev/null | head -1)
        if [ -z "$ISO" ]; then
          echo "ERROR: No ISO found. Run 'just iso build' first."
          exit 1
        fi
        echo "Flashing: $ISO"
        echo "Target:   $DRIVE"
        echo ""
        read -rp "This will ERASE $DRIVE. Type YES to continue: " CONFIRM
        if [ "$CONFIRM" != "YES" ]; then
          echo "Aborted."
          exit 1
        fi
        sudo dd if="$ISO" of="$DRIVE" bs=4M status=progress oflag=sync
        echo ""
        echo "Flash complete. Safe to remove drive."
        ;;
      delete)
        if [ -L result ]; then
          rm -f result
          echo "ISO deleted."
        else
          echo "No ISO to delete."
        fi
        ;;
      *)
        echo "Usage: just iso <action>"
        echo ""
        echo "Actions:"
        echo "  build          Build the installer ISO"
        echo "  flash <drive>  Flash the ISO to a USB drive"
        echo "  delete         Remove the built ISO"
        ;;
    esac

# === Maintenance ===

# Clean VM artifacts
clean:
    rm -rf result {{hostname}}.qcow2

# Install/update git hooks
hooks:
    nix develop .#nix --no-pure-eval --command prek install --install-hooks

# Format all Nix files
fmt:
    nix develop .#nix --no-pure-eval --command nixfmt .

# Fix auto-fixable issues
fix:
    nix develop .#nix --no-pure-eval --command sh -c "statix fix . && deadnix --edit . && nixfmt ."
