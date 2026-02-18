{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist-games".directories = [
    "/games/itch"
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      itch
    ];

    home.persistence."/persist".directories = [
      ".config/itch"
    ];
  };
}
