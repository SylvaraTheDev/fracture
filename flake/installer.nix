{ inputs, ... }:

{
  perSystem =
    { system, pkgs, ... }:
    let
      installer = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          inputs.disko.nixosModules.disko

          (
            { lib, ... }:
            {
              networking = {
                hostName = "fracture-installer";
                wireless.enable = lib.mkForce false;
                networkmanager.enable = true;
              };

              nix.settings.experimental-features = [
                "nix-command"
                "flakes"
              ];

              environment = {
                # Embed the Fracture flake source
                etc."fracture/flake".source = builtins.path {
                  path = ../.;
                  name = "fracture-flake";
                  filter =
                    path: _type:
                    let
                      base = baseNameOf path;
                    in
                    !builtins.elem base [
                      ".devenv"
                      ".direnv"
                      ".git"
                      "result"
                    ];
                };

                # Embed the age keyfile
                # Create this file before building: cp ~/.config/sops/age/keys.txt secrets/age-keyfile
                etc."fracture/age-keys.txt" = {
                  source = ../secrets/age-keyfile;
                  mode = "0400";
                };

                systemPackages =
                  (with pkgs; [
                    git
                    rsync
                    sops
                    age
                    jq
                    btrfs-progs
                    dosfstools
                    nvme-cli
                    gptfdisk
                    inputs.disko.packages.${system}.disko
                  ])
                  ++ [
                    (pkgs.writeShellScriptBin "docs" "less ${pkgs.writeText "docs.txt" (builtins.readFile ../scripts/installer/docs.txt)}")
                    (pkgs.writeShellScriptBin "fracture-wipe" (builtins.readFile ../scripts/installer/wipe.sh))
                    (pkgs.writeShellScriptBin "fracture-install" (builtins.readFile ../scripts/installer/install.sh))
                  ];
              };
            }
          )
        ];
      };
    in
    {
      packages.installer-iso = installer.config.system.build.isoImage;
    };
}
