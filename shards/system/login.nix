{
  config,
  pkgs,
  ...
}:

{
  services = {
    # Auto-login for VM testing
    getty.autologinUser = config.fracture.user.login;

    # Use greetd with Niri for graphical login
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.niri}/bin/niri-session";
          user = config.fracture.user.login;
        };
      };
    };

    # Disable SDDM (using greetd instead for VM)
    displayManager.sddm.enable = false;
  };
}
