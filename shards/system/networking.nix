{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        7865
        14159
        8000
        34197
      ];
      allowedUDPPorts = [
        7865
        14159
        8000
        34197
      ];
    };
  };

  environment.persistence."/persist".directories = [
    "/etc/NetworkManager/system-connections"
  ];
}
