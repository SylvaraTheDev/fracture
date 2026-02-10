{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    glib
    nss
    nspr
    cups
    gtk3
    gtk2
    dbus
    atk
    at-spi2-atk
    cairo
    gdk-pixbuf
    pango
    libgbm
    libxcb
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxrender
    libxtst
    alsa-lib
    libpulseaudio
    libdrm
    mesa
    systemd
    expat
    libxkbcommon
  ];
}
