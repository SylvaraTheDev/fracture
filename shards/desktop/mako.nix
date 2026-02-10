{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  environment.systemPackages = with pkgs; [
    swaybg
  ];

  home-manager.users.${login} = _: {
    services.mako = {
      enable = true;
      settings = {
        default-timeout = 5000;
        border-size = 2;
        border-radius = 10;
        max-visible = 5;
        # Colors and font are managed by Stylix
      };
    };
  };
}
