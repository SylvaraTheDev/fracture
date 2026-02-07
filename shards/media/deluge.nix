{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      deluge
    ];

    home.persistence."/persist".directories = [
      ".config/deluge"
    ];
  };
}
