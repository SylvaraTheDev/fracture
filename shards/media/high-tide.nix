{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      high-tide
    ];

    home.persistence."/persist".directories = [
      ".config/high-tide"
      ".local/share/high-tide"
    ];
  };
}
