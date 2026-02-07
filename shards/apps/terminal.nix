{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.ghostty.enable = true;

    home.persistence."/persist".directories = [
      ".config/ghostty"
    ];
  };
}
