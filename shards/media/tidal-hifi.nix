{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  tidal-hifi-wayland = pkgs.symlinkJoin {
    name = "tidal-hifi";
    paths = [ pkgs.tidal-hifi ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/tidal-hifi \
        --add-flags "--ozone-platform=wayland" \
        --add-flags "--enable-features=UseOzonePlatform,WaylandWindowDecorations" \
        --add-flags "--enable-wayland-ime"
    '';
  };
in
{
  home-manager.users.${login} = _: {
    home.packages = [
      tidal-hifi-wayland
    ];

    home.persistence."/persist".directories = [
      ".config/tidal-hifi"
    ];
  };
}
