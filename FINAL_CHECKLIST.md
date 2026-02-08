# Fracture - Final Checklist

Deferred items from the codebase refactor. Address these before deploying to hardware.

## Disk Option Placeholders

`shards/options.nix` defines meaningless default values for disk options (`PLACEHOLDER_BOOT_NVME`, etc.).
Remove these defaults so Nix fails at eval time if `host.nix` doesn't provide real values. Use `lib.mkOption`
without a `default` field for required options, or use `null` with an assertion.

**Files**: `shards/options.nix`, `host.nix`

## Update host.nix Disk IDs

Replace the placeholder disk device paths in `host.nix` with actual `/dev/disk/by-id/` paths for the target
hardware before building for bare metal.

**File**: `host.nix`

## SSH Hardening

Currently `PermitRootLogin = "yes"` and `PasswordAuthentication = true` are set unconditionally. Consider
gating these on `config.fracture.vm.enable` before deploying to a network-accessible machine.

**File**: `shards/system/ssh.nix`

## Populate SOPS Secrets

`secrets/auth/users.yaml` still contains `PLACEHOLDER` password hashes. Generate real hashed passwords
and encrypt them with sops before first boot.

**Files**: `secrets/auth/users.yaml`, `secrets/api/keys.yaml`, `secrets/ssh/config.yaml`
