{ config, pkgs, ... }:

{
  # === Bootloader ===
  boot = {
    loader = {
      limine = {
        enable = true;
        efiSupport = true;
        maxGenerations = 10;
      };
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    extraModprobeConfig = ''
      options snd_hda_intel power_save=0
    '';
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
        "https://nix-gaming.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
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

    # === Packages ===
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
      btop
      btrfs-progs
      xdg-utils
      unrar
      unzip
      inotify-tools
      jq
      nixfmt

      # System
      upower
      xwayland
      gtk4-layer-shell
      xdg-dbus-proxy
      libsecret
      mono
      greetd
    ];

    persistence."/persist".directories = [
      "/var/lib/bluetooth"
    ];
  };

  # === Fonts ===
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
  ];

  # === Services ===
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    dbus.enable = true;
    upower.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
