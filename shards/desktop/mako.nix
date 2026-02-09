{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  environment.systemPackages = with pkgs; [
    mako
    swaybg
  ];

  home-manager.users.${login} = _: {
    home.file.".config/mako" = {
      source = dotfiles + "/mako";
      recursive = true;
      force = true;
    };
  };
}
