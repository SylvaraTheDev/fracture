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

  # XWayland support via xwayland-satellite (Niri has no built-in XWayland)
  # Screenshot tools: grim (capture) + slurp (region select) + wl-clipboard (clipboard)
  environment.systemPackages = [
    pkgs.xwayland-satellite
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard
  ];

  programs.niri.enable = true;
  programs.niri.package =
    inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable.overrideAttrs
      (_old: {
        doCheck = false;
      });

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
