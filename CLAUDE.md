# Fracture — NixOS System Configuration

## Project Structure
- **Flake-parts** architecture: `flake.nix` → `flake/imports.nix` → `flake/{system,devshells,treefmt,installer}.nix`
- **Shards** pattern: every `.nix` file in `shards/` is auto-discovered as a NixOS module (via `findModules` in `flake/system.nix`)
- **Options** namespace: all custom options under `fracture.*` defined in `shards/options.nix`
- **Dotfiles**: managed configs in `dotfiles/`, synced to `~` via `home.file`
- **Secrets**: SOPS-encrypted in `secrets/`, decrypted via sops-nix with age keys

## Shard Conventions
- Each shard is a standalone NixOS module: `{ config, lib, pkgs, ... }: { ... }`
- Home-manager config uses: `home-manager.users.${config.fracture.user.login} = ...`
- Categories: `system/`, `desktop/`, `dev/`, `ai/`, `gaming/`, `media/`, `shell/`, `communication/`, `containers/`
- The `shells/` subdirectory under `dev/` is excluded from auto-discovery (devshells loaded separately)
- Reference `config.fracture.dotfilesDir` for dotfile paths, never hardcode

## Persistence (Impermanence)
- Root filesystem is ephemeral — wiped on boot
- Persist directories via `home.persistence."/persist".directories`
- Persist files via `home.persistence."/persist".files`
- System-level persistence in `shards/system/persist.nix`
- Three persist volumes: `/persist` (system/user), `/persist-projects`, `/persist-games`

## Build & Test
- `just check` — run pre-commit hooks (treefmt + gitleaks + hygiene)
- `just fmt` — format all Nix files via treefmt
- `just verify` — dry-run build verification
- `just run` — build and run VM with graphics + serial console
- `nix flake check` — validate flake (pre-push hook)
- `nix fmt -- --fail-on-change` — CI-style format check

## Formatting
- **treefmt** with: nixfmt (formatting), statix (static analysis), deadnix (dead code detection)
- Pre-commit via prek (Rust-based runner)
- Secret scanning via gitleaks

## Key Files
- `shards/options.nix` — all `fracture.*` option definitions
- `flake/system.nix` — nixosSystem definition and shard discovery
- `host.nix` — host-specific values (user, disks, GPU, timezone)
- `hardware.nix` — hardware-specific config
