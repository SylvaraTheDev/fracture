{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      krita
    ];

    home.persistence."/persist".directories = [
      ".config/krita-scripter"
      ".local/share/krita"
    ];

    home.persistence."/persist".files = [
      ".config/kritarc"
      ".config/kritadisplayrc"
    ];
  };
}
