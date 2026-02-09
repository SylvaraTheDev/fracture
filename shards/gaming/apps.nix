{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  # Gamescope needs system-level capabilities
  environment.systemPackages = with pkgs; [
    gamescope
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      protonup-qt
      winetricks
      protontricks
    ];
  };
}
