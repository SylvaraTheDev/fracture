{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Dotfiles Infrastructure
  # Maps files from 'dotfiles/' directory to user home

  home-manager.users.elyria =
    { config, ... }:
    {
      # Helper to get the path to the dotfiles directory relative to the flake root
      # Note: explicit paths are safer than relative paths that might change

      # Modern Home Manager Syntax: xdg.configFile (for .config) and home.file

      xdg.configFile = {
        "mako".source = ../../dotfiles/mako;
        "nushell".source = ../../dotfiles/nushell;
        "fastfetch/images".source = ../../dotfiles/fastfetch/images;
        "deckmaster".source = ../../dotfiles/deckmaster;
      };

      programs.starship.enable = true;

      # Cursor Theme (migrated from old dotfiles module)
      home.pointerCursor = {
        name = "Bibata-Modern-Ice";
        size = 24;
        package = pkgs.bibata-cursors;
        gtk.enable = true;
        x11.enable = true;
      };

      # Session variables
      home.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Ice";
        XCURSOR_SIZE = "24";
      };
    };
}
