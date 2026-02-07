{ inputs, ... }:
{
  imports = [
    inputs.devenv.flakeModule
    ./system.nix
    ./devshells.nix
  ];
}
