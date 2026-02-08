{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      lutris
    ];

    home.persistence."/persist".directories = [
      ".local/share/lutris"
    ];
  };
}
