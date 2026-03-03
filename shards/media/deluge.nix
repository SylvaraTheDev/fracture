{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.fracture.user) login;

  delugeVpn = pkgs.writeShellScriptBin "deluge" ''
    exec sudo ${pkgs.iproute2}/bin/ip netns exec airvpn sudo -u "$USER" -- ${lib.getExe' pkgs.deluge "deluge"} "$@"
  '';
in
{
  home-manager.users.${login} = _: {
    home.packages = [ delugeVpn ];

    xdg.desktopEntries.deluge = {
      name = "Deluge";
      exec = "${delugeVpn}/bin/deluge %U";
      icon = "deluge";
      comment = "BitTorrent Client (via AirVPN)";
      categories = [
        "Network"
        "FileTransfer"
        "P2P"
      ];
    };

    home.persistence."/persist".directories = [
      ".config/deluge"
    ];
  };
}
