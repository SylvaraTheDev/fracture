{ inputs, ... }:
{
  imports = [
    inputs.devenv.flakeModule
    inputs.treefmt-nix.flakeModule
    ./system.nix
    ./devshells.nix
    ./installer.nix
    ./treefmt.nix
  ];
}
