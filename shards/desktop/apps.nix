{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      obsidian
      mission-center
      thunar
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
