# Fracture - NixOS VM Configuration
# ===================================

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
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -serial mon:stdio -m 4096" ./result/bin/run-fracture-vm

# Run with graphics only (no terminal)
run-graphics: check
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -m 4096" ./result/bin/run-fracture-vm

# Run with serial console only (no graphics)
run-console: check
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-nographic -serial mon:stdio -m 4096" ./result/bin/run-fracture-vm

# Dry run verification
verify: check
    nixos-rebuild build --flake .#fracture --dry-run

# === Unsafe Operations (skip checks) ===

# Build and run WITHOUT safety checks (use carefully)
run-unsafe:
    just clean
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -serial mon:stdio -m 4096" ./result/bin/run-fracture-vm

# Verify WITHOUT safety checks
verify-unsafe:
    nixos-rebuild build --flake .#fracture --dry-run

# === Maintenance ===

# Clean VM artifacts
clean:
    rm -rf result fracture.qcow2

# Install/update git hooks
hooks:
    nix develop .#nix --no-pure-eval --command prek install --install-hooks

# Format all Nix files
fmt:
    nix develop .#nix --no-pure-eval --command nixfmt .

# Fix auto-fixable issues
fix:
    nix develop .#nix --no-pure-eval --command sh -c "statix fix . && deadnix --edit . && nixfmt ."
