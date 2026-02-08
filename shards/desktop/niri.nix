{
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  # Import niri-flake NixOS module
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;

  # XDG Portals (compositor-specific)
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
  };

  # Link niri config from dotfiles
  home-manager.users.${login} = _: {
    home.file.".config/niri" = {
      source = dotfiles + "/niri";
      recursive = true;
      force = true;
    };
  };
}
