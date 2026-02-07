{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "Aura";
        gtk-single-instance = false;
        gtk-titlebar = false;
        window-decoration = true;
      };
    };

    home.persistence."/persist".directories = [
      ".config/ghostty"
    ];
  };
}
