{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Auto-login for VM testing
  services.getty.autologinUser = "elyria";

  # Use greetd with Niri for graphical login
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "elyria";
      };
    };
  };

  # Disable SDDM (using greetd instead for VM)
  services.displayManager.sddm.enable = false;
}
