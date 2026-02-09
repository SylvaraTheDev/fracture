{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.fracture.obsidian;
  inherit (config.fracture.user) login;
in
{
  options.fracture.obsidian = {
    basePath = lib.mkOption {
      type = lib.types.str;
      default = "/projects/obsidian";
      description = "Base directory for Obsidian vaults.";
    };

    vaults = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              description = "Display name of the vault.";
            };
          };
        }
      );
      default = { };
      description = "Obsidian vaults to manage.";
    };
  };

  config = lib.mkIf (cfg.vaults != { }) {
    environment.persistence."/persist-projects".directories = [
      "/projects/obsidian"
    ];

    # Create vault directories on activation
    systemd.tmpfiles.rules = lib.mapAttrsToList (
      id: _vault: "d ${cfg.basePath}/${id} 0755 ${login} users -"
    ) cfg.vaults;

    home-manager.users.${login} = _: {
      home.packages = [ pkgs.obsidian ];

      home.persistence."/persist".directories = [
        ".config/obsidian"
      ];
    };
  };
}
