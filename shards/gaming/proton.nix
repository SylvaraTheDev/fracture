{ pkgs, ... }:

{
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # Per-game Wayland opt-in via Steam launch options:
  #   PROTON_ENABLE_WAYLAND=1 %command%
  # Not set globally because some DX12/VKD3D-Proton titles crash with it.
}
