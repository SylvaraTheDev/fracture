{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Import niri-flake NixOS module (automatically imports home-manager config module)
  imports = [ inputs.niri.nixosModules.niri ];

  # Enable Niri via niri-flake
  programs.niri.enable = true;

  # Use niri-stable from the flake (with binary cache)
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  # XDG Portals
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.common.default = [ "gtk" ];
  };

  # Configure Niri via Home Manager (niri-flake auto-imports its config module)
  home-manager.users.${config.fracture.user.login} =
    { pkgs, ... }:
    {
      # Wallpapers and compositor config
      xdg.configFile."niri/wallpapers".source = ../../dotfiles/niri/wallpapers;

      # Cursor theme
      home.pointerCursor = {
        name = "Bibata-Modern-Ice";
        size = 24;
        package = pkgs.bibata-cursors;
        gtk.enable = true;
        x11.enable = true;
      };

      home.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
      };

      # Don't import niri.homeModules.niri - it's auto-imported by NixOS module
      programs.niri = {
        settings = {
          # Spawn Noctalia at startup
          spawn-at-startup = [
            { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
            { command = [ "noctalia-shell" ]; }
            # { command = [ "ghostty" ]; }
          ];

          # Basic layout
          layout = {
            gaps = 8;
            border = {
              enable = true;
              width = 2;
            };
          };

          # Input settings
          input = {
            keyboard.xkb = { };
            mouse = {
              accel-speed = 0.0;
            };
          };
        };
      };
    };
}
