{ config, pkgs, ... }:

let
  dotfiles = config.fracture.dotfilesDir;
in
{
  stylix = {
    enable = true;
    polarity = "dark";
    image = dotfiles + "/niri/wallpapers/deltahub-white.jpg";

    base16Scheme = {
      scheme = "Fracture Neon Abyss";
      author = "Sylvara";
      base00 = "0d0a14"; # Background — near-black, purple undertone
      base01 = "1a1228"; # Raised background — very dark purple
      base02 = "2d1f42"; # Selection — dark purple
      base03 = "453560"; # Comments — muted purple
      base04 = "6a5590"; # Dark foreground — dusty purple
      base05 = "c4b4e0"; # Foreground — soft lavender
      base06 = "ddd0f0"; # Light foreground — lighter lavender
      base07 = "f0e8ff"; # Brightest — near-white with purple tint
      base08 = "ff2a6d"; # Hot pink — errors, variables
      base09 = "ff5c8a"; # Warm pink — constants, numbers
      base0A = "e838a0"; # Magenta-pink — classes, warnings
      base0B = "4488cc"; # Subtle blue — strings, success
      base0C = "6c5ce7"; # Blue-purple — support, regex
      base0D = "5078c0"; # Medium blue — functions
      base0E = "b844e0"; # Bright purple — keywords
      base0F = "d02878"; # Deep pink — deprecated, special
    };

    fonts = {
      monospace = {
        name = "FiraCode Nerd Font";
        package = pkgs.nerd-fonts.fira-code;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
    };

    cursor = {
      name = "Bibata-Modern-Ice";
      size = 24;
      package = pkgs.bibata-cursors;
    };

  };
}
