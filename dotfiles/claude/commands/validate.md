Run full validation on the Fracture NixOS configuration.

## Instructions

Run these checks in order, stopping on first failure:

1. **Format check**: `nix fmt -- --fail-on-change`
   - If this fails, run `nix fmt` to fix, then report what changed

2. **Flake check**: `nix flake check`
   - Validates flake structure and evaluates the configuration

3. **Dry-run build**: `nixos-rebuild build --flake .#fracture --dry-run`
   - Verifies the full system build would succeed

Report the results of each step. If all pass, confirm the configuration is valid.
