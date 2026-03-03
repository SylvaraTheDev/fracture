{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.persistence."/persist".directories = [
    "/root/go/pkg"
  ];

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      go
    ];

    home.persistence."/persist".directories = [
      ".cache/go-build"
      "go/pkg"
    ];
  };
}
