{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      signal-desktop-bin
    ];

    home.persistence."/persist".directories = [
      ".config/Signal"
    ];
  };
}
