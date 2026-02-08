{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture) user;
in
{
  # Auto-login on TTY only in VM mode
  services.getty.autologinUser = lib.mkIf config.fracture.vm.enable user.login;

  # Fix NVIDIA hardware cursor bug in cage (regreet's compositor)
  systemd.services.greetd.environment = lib.mkIf (config.fracture.gpu == "nvidia") {
    WLR_NO_HARDWARE_CURSORS = "1";
  };

  programs.regreet = {
    enable = true;
    settings = {
      appearance.greeting_msg = "Welcome to Fracture";
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "FiraCode Nerd Font";
      size = 14;
      package = pkgs.nerd-fonts.fira-code;
    };
  };
}
