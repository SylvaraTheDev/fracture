Create a new shard module in the Fracture NixOS configuration.

## Arguments
- `$ARGUMENTS` should be in the format: `<category> <name>` (e.g., `desktop firefox` or `dev rust`)

## Instructions

1. Parse the category and name from `$ARGUMENTS`
2. Create the file at `shards/<category>/<name>.nix`
3. Use this template as the starting structure:

```nix
{ config, lib, pkgs, ... }:

let
  user = config.fracture.user.login;
in
{
  # System-level configuration


  home-manager.users.${user} = {
    # Home-manager configuration


    home.persistence."/persist".directories = [
      # Directories to persist across reboots (root is ephemeral)
    ];
  };
}
```

## Rules
- Every shard is a standalone NixOS module auto-discovered by `findModules`
- Use `config.fracture.dotfilesDir` for dotfile paths, never hardcode
- Use `config.fracture.secretsDir` for secret paths
- Always consider what needs persistence (impermanence — root is wiped on boot)
- Reference `config.fracture.gpu`, `config.fracture.vm.enable`, etc. for conditional config
- Check `shards/options.nix` for all available `fracture.*` options
- Follow existing patterns in the same category for structure cues
