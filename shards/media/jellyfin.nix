{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      jellyfin
    ];

    home.persistence."/persist".directories = [
      ".local/share/jellyfinmediaplayer"
    ];
  };
}
