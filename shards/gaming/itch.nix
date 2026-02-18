{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist-games".directories = [
    {
      directory = "/games/itch";
      user = login;
      group = "users";
      mode = "0755";
    }
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
