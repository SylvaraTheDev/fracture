{
  config,
  lib,
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
    cageArgs = [
      "-s"
      "-m"
      "last"
    ];
    settings = {
      appearance.greeting_msg = "Welcome to Fracture";
      GTK.application_prefer_dark_theme = true;
    };
  };

  # Pre-seed regreet state to default to Niri for the primary user
  environment.etc."greetd/regreet-state.toml".text = ''
    last_user = "${user.login}"

    [user_sessions]
    ${user.login} = "niri-session"
  '';

  systemd.tmpfiles.rules = [
    "C /var/lib/regreet/state.toml 0600 greeter greeter - /etc/greetd/regreet-state.toml"
  ];
}
