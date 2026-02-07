{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.systemPackages = with pkgs; [
    easyeffects
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      plex-desktop
      pwvucontrol
      playerctl
      pamixer
    ];
  };
}
