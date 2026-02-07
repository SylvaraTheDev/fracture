{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.systemPackages = with pkgs; [
    obsidian
    mission-center
    thunar
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      blueman
      localsend
      pinta
      kdePackages.ark
      motrix
      mediawriter
      appimage-run
      ladybird
    ];
  };
}
