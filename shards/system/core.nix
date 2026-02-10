{ config, pkgs, ... }:

{
  # === Bootloader ===
  boot.loader = {
    limine = {
      enable = true;
      efiSupport = true;
      maxGenerations = 10;
      # Secure Boot via Limine — requires manual key enrollment:
      #   1. sbctl create-keys
      #   2. BIOS: reset Secure Boot to Setup Mode
      #   3. sbctl enroll-keys -m -f
      #   4. BIOS: enable Secure Boot
      #   5. Rebuild
      secureBoot.enable = !config.fracture.vm.enable;
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
      accept-flake-config = true;
      warn-dirty = false;
      substituters = [
        "https://cache.nixos.org/"
        "https://cache.nixos-cuda.org"
        "https://niri.cachix.org"
        "https://vicinae.cachix.org"
        "https://cache.flox.dev"
        "https://attic.xuyh0120.win/lantian"
        "https://cache.garnix.io"
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      ];
    };
    package = pkgs.lixPackageSets.stable.lix;
  };

  nixpkgs.config.allowUnfree = true;
  programs.command-not-found.enable = false;
  programs.nix-index-database.comma.enable = true;

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

      # Secure Boot
      sbctl

      # System
      upower
      xwayland
      gtk4-layer-shell
      xdg-dbus-proxy
      libsecret
      mono

      # Recovery terminal (system-level, independent of home-manager)
      alacritty
    ];
  };

  services = {
    dbus.enable = true;
    upower.enable = true;
  };

  # Persist Secure Boot signing keys across reboots
  environment.persistence."/persist".directories = [
    "/var/lib/sbctl"
  ];
}
