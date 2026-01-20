{
  config,
  pkgs,
  inputs,
  ...
}:

{
  users.users.elyria = {
    isNormalUser = true;
    description = "Elyria";
    initialPassword = "1142";
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "input"
      "docker"
      "podman"
      "kvm"
    ];
    shell = pkgs.nushell;
    ignoreShellProgramCheck = true;
  };

  home-manager.users.elyria =
    { pkgs, ... }:
    {
      home.stateVersion = "25.11";
      home.username = "elyria";
      home.homeDirectory = "/home/elyria";

      # XDG
      xdg.enable = true;
      home.sessionVariables = {
        XDG_DATA_DIRS = "$HOME/.nix-profile/share:$XDG_DATA_DIRS";
        # For synced terminal/GUI in VM - connect to Niri Wayland session
        WAYLAND_DISPLAY = "wayland-1";
        XDG_RUNTIME_DIR = "/run/user/1000";
      };

      programs.git = {
        enable = true;
        settings = {
          user.name = "Elyria";
          user.email = "wing@elyria.dev";
        };
      };

      programs.starship.enable = true;
    };
}
