{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      r2modman
    ];

    home.persistence."/persist".directories = [
      ".config/r2modman"
    ];
  };
}
