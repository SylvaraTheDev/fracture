{ pkgs, ... }:

{
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];
}
