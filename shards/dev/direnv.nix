{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      direnv
      nix-direnv
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home.persistence."/persist".directories = [
      ".local/share/direnv"
    ];
  };
}
