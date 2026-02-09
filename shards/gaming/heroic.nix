{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist-games".directories = [
    "/games/heroic"
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      heroic
    ];

    home.persistence."/persist".directories = [
      ".config/heroic"
    ];
  };
}
