{
  pkgs,
  ...
}:

{
  services = {
    # Auto-login for VM testing
    getty.autologinUser = "elyria";

    # Use greetd with Niri for graphical login
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.niri}/bin/niri-session";
          user = "elyria";
        };
      };
    };

    # Disable SDDM (using greetd instead for VM)
    displayManager.sddm.enable = false;
  };
}
