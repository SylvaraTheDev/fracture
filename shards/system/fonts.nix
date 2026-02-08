{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts-color-emoji
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
  ];
}
