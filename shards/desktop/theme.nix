{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} =
    { pkgs, ... }:
    {
      home = {
        # Cursor theme
        pointerCursor = {
          name = "Bibata-Modern-Ice";
          size = 24;
          package = pkgs.bibata-cursors;
          gtk.enable = true;
          x11.enable = true;
        };

        sessionVariables = {
          XCURSOR_THEME = "Bibata-Modern-Ice";
          XCURSOR_SIZE = "24";
        };
      };

      # Dark mode
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
}
