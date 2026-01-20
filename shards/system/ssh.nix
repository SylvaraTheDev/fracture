{ config, pkgs, ... }:

{
  # Enable SSH for VM access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };
}
