{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      mission-center
      blueman
      kdePackages.ark
      motrix
      mediawriter
      appimage-run
      ladybird
      cosmic-files
    ];
  };
}
