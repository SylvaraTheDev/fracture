# Run VM with both graphics AND serial console (synced session)
run:
    just clean
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -serial mon:stdio -m 4096" ./result/bin/run-fracture-vm

# Run with graphics only (no terminal)
run-graphics:
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-device virtio-vga-gl -display gtk,gl=on -m 4096" ./result/bin/run-fracture-vm

# Run with serial console only (no graphics)
run-console:
    nixos-rebuild build-vm --flake .#fracture
    QEMU_OPTS="-nographic -serial mon:stdio -m 4096" ./result/bin/run-fracture-vm

# Dry run verify
verify:
    nixos-rebuild build --flake .#fracture --dry-run

# Clean VM artifacts (results and disk image)
clean:
    rm -rf result fracture.qcow2
