{ config, pkgs, ... }:

{
  # === Bootloader ===
  boot.loader = {
    limine = {
      enable = true;
      efiSupport = true;
      maxGenerations = 10;
    };
    timeout = 1;
    efi.canTouchEfiVariables = true;
  };

  # === Nix Settings ===
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org/"
        "https://vicinae.cachix.org"
        "https://cache.flox.dev"
        "https://attic.xuyh0120.win/lantian"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
    };
    package = pkgs.lixPackageSets.stable.lix;
  };

  nixpkgs.config.allowUnfree = true;
  programs.command-not-found.enable = true;

  # === Base System Configuration ===
  time.timeZone = config.fracture.timezone;
  i18n.defaultLocale = config.fracture.locale;

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      # Core
      coreutils-full
      busybox
      libgcc
      gccgo

      # Utils
      git
      git-lfs
      wget
      gnupg
      tree
      btrfs-progs
      xdg-utils
      unrar
      unzip
      inotify-tools
      jq

      # System
      upower
      xwayland
      gtk4-layer-shell
      xdg-dbus-proxy
      libsecret
      mono
    ];
  };

  services = {
    dbus.enable = true;
    upower.enable = true;
  };
}
