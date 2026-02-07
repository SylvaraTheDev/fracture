{ pkgs, ... }:

{
  # === Bootloader ===
  boot.loader.limine.enable = true;
  boot.loader.limine.efiSupport = true;
  boot.loader.limine.maxGenerations = 10;
  boot.loader.timeout = 1;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
  '';

  # === Nix Settings ===
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];
  nix.settings.warn-dirty = false;

  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://vicinae.cachix.org"
    "https://cache.flox.dev"
    "https://attic.xuyh0120.win/lantian"
    "https://nix-gaming.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
    "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
  ];

  nixpkgs.config.allowUnfree = true;
  nix.package = pkgs.lixPackageSets.stable.lix;
  programs.command-not-found.enable = true;

  # === Base System Configuration ===
  time.timeZone = "Australia/Brisbane";
  i18n.defaultLocale = "en_AU.UTF-8";

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # === Packages ===
  environment.systemPackages = with pkgs; [
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

    # Apps (System wide)
    zed-editor
    obsidian
    mission-center
    easyeffects
    thunar
    zenith-nvidia
    adoptopenjdk-icedtea-web

    # Custom/Other
    greetd
  ];

  # === Fonts ===
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
  ];

  # === Services ===
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.dbus.enable = true;
  services.upower.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
}
