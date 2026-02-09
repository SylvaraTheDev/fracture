{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      bottles
    ];

    home.persistence."/persist".directories = [
      ".local/share/bottles"
    ];
  };
}
