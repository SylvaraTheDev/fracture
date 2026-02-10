{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      tonearm
    ];

    home.persistence."/persist".directories = [
      ".config/tonearm"
      ".local/share/tonearm"
    ];
  };
}
