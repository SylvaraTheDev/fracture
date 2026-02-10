{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  # Gamescope with capability wrappers for realtime scheduling
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      protonup-qt
      winetricks
      protontricks
      mangohud
      goverlay
    ];
  };
}
