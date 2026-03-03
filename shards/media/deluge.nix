{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  networking.firewall = {
    allowedTCPPorts = [ 6881 ];
    allowedUDPPorts = [ 6881 ];
  };

  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      deluge
    ];

    home.persistence."/persist".directories = [
      ".config/deluge"
    ];
  };
}
