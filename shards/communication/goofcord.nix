{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  goofcord-wayland = pkgs.goofcord.overrideAttrs (prev: {
    installPhase = (prev.installPhase or "") + ''
      wrapProgram $out/bin/goofcord \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations" \
        --add-flags "--enable-wayland-ime"
    '';
  });
in
{
  home-manager.users.${login} = _: {
    home.packages = [
      goofcord-wayland
    ];

    home.persistence."/persist".directories = [
      ".config/goofcord"
    ];
  };
}
