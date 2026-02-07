{
  config,
  pkgs,
  ...
}:

{
  sops.secrets."users/elyria/password" = {
    sopsFile = ../../secrets/auth/users.yaml;
    neededForUsers = true;
  };

  users.users.elyria = {
    isNormalUser = true;
    description = "Elyria";
    hashedPasswordFile = config.sops.secrets."users/elyria/password".path;
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "podman"
      "kvm"
    ];
    shell = pkgs.nushell;
    ignoreShellProgramCheck = true;
  };

  home-manager.users.elyria = _: {
    home = {
      stateVersion = "25.11";
      username = "elyria";
      homeDirectory = "/home/elyria";
      sessionVariables = {
        XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
        # For synced terminal/GUI in VM - connect to Niri Wayland session
        WAYLAND_DISPLAY = "wayland-1";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };
    };

    # XDG
    xdg.enable = true;

    programs.git = {
      enable = true;
      settings = {
        user.name = "Elyria";
        user.email = "wing@elyria.dev";
      };
    };
  };
}
