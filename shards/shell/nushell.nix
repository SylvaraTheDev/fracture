{ config, ... }:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  home-manager.users.${login} = _: {
    programs.nushell = {
      enable = true;
      extraConfig = builtins.readFile (dotfiles + "/nushell/config.nu");
    };
    programs.starship.enable = true;

    # Functions directory (not managed by nushell module)
    home.file.".config/nushell/functions" = {
      source = dotfiles + "/nushell/functions";
      recursive = true;
      force = true;
    };

    home.persistence."/persist".directories = [
      ".local/share/nushell"
    ];
  };
}
