{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      godot
    ];

    home.persistence."/persist".directories = [
      ".config/godot"
      ".local/share/godot"
    ];
  };

  environment.persistence."/persist-projects".directories = [
    "/projects/godot"
  ];
}
