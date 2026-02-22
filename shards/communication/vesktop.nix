{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  vesktop-gpu = pkgs.vesktop.overrideAttrs (prev: {
    preFixup = (prev.preFixup or "") + ''
      makeWrapperArgs+=(
        --set ELECTRON_EXTRA_LAUNCH_FLAGS "--use-gl=angle --use-angle=opengl --ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy --disable-gpu-driver-bug-workarounds"
        --append-flags "--enable-features=VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks"
      )
    '';
  });
in
{
  home-manager.users.${login} = _: {
    home.packages = [
      vesktop-gpu
    ];

    home.persistence."/persist".directories = [
      ".config/vesktop"
    ];
  };
}
