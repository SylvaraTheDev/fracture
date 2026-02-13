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
    specialArgs = { inherit inputs; };
    modules = [
      ../hardware.nix
      ../host.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.sops-nix.nixosModules.sops
      inputs.disko.nixosModules.disko
      inputs.impermanence.nixosModules.impermanence
      inputs.stylix.nixosModules.stylix
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.nix-index-database.nixosModules.nix-index
      { _module.args.__isDevShell = false; }
      (
        { config, ... }:
        {
          networking.hostName = config.fracture.hostname;
          system.stateVersion = config.fracture.stateVersion;
          home-manager.useGlobalPkgs = true;
          home-manager.backupFileExtension = "nixbak";
          programs.dconf.enable = true;
        }
      )
    ]
    ++ (findModules ../shards);
  };
}
