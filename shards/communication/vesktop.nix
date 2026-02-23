{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  vesktop-gpu = pkgs.symlinkJoin {
    name = "vesktop";
    paths = [ pkgs.vesktop ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vesktop \
        --prefix LD_LIBRARY_PATH : "/run/opengl-driver/lib" \
        --add-flags "--enable-features=VaapiVideoDecodeLinuxGL,VaapiIgnoreDriverChecks" \
        --add-flags "--ignore-gpu-blocklist" \
        --add-flags "--enable-gpu-rasterization" \
        --add-flags "--enable-zero-copy" \
        --add-flags "--enable-features=WebRTCPipeWireCapturer"
    '';
  };
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
