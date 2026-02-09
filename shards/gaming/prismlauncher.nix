{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist-games".directories = [
    "/games/prismlauncher"
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      prismlauncher
    ];

    home.persistence."/persist".directories = [
      ".local/share/PrismLauncher"
    ];
  };
}
