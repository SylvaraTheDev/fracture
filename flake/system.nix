{ inputs, ... }:
let
  # Recursively discover all .nix files in a directory tree
  findModules =
    dir:
    let
      entries = builtins.readDir dir;
      processEntry =
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "directory" then
          findModules path
        else if type == "regular" && inputs.nixpkgs.lib.strings.hasSuffix ".nix" name then
          [ path ]
        else
          [ ];
    in
    inputs.nixpkgs.lib.lists.flatten (inputs.nixpkgs.lib.mapAttrsToList processEntry entries);
in
{
  flake.nixosConfigurations.fracture = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      ../hardware.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      {
        networking.hostName = "fracture";
        system.stateVersion = "25.11";
      }
    ]
    ++ (findModules ../shards);
  };
}
