{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  networking.firewall = {
    allowedTCPPorts = [ 51702 ];
    allowedUDPPorts = [ 51702 ];
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
