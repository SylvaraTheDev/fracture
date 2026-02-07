{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      bitwarden-desktop
      bitwarden-cli
    ];

    home.persistence."/persist".directories = [
      ".config/Bitwarden"
    ];
  };
}
