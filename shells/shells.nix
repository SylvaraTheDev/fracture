{ lib, inputs, ... }:
let
  importers = import ../lib/importers.nix { inherit lib; };
in
{
  perSystem =
    { pkgs, system, ... }:
    let
      mkDevShell = import ../lib/shells.nix { inherit inputs pkgs; };
      shells = importers.importShells ./.;
    in
    {
      devShells = lib.mapAttrs (n: v: v { inherit pkgs mkDevShell; }) shells;
    };
}
