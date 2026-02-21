{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = [
      pkgs.notion-app
    ];

    home.persistence."/persist".directories = [
      ".config/Notion"
    ];
  };
}
