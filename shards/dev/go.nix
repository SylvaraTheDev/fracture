{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      go
    ];

    home.persistence."/persist".directories = [
      ".cache/go-build"
    ];
  };
}
