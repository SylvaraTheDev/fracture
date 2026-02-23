{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;

  krita-ai-diffusion = pkgs.fetchFromGitHub {
    owner = "Acly";
    repo = "krita-ai-diffusion";
    rev = "v1.48.0";
    hash = "sha256-YXOmf6rBYPInug4Da010BUhFx//F7od/ebCPovCVZlU=";
  };
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      krita
    ];

    home.activation.linkKritaAiDiffusion = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p ~/.local/share/krita/pykrita
      ln -sfn "${krita-ai-diffusion}/ai_diffusion" ~/.local/share/krita/pykrita/ai_diffusion
      ln -sf "${krita-ai-diffusion}/ai_diffusion.desktop" ~/.local/share/krita/pykrita/ai_diffusion.desktop
    '';

    home.persistence."/persist".directories = [
      ".config/krita-scripter"
      ".local/share/krita"
    ];

    home.persistence."/persist".files = [
      ".config/kritarc"
      ".config/kritadisplayrc"
    ];
  };

  environment.persistence."/persist-projects".directories = [
    {
      directory = "/projects/krita";
      user = login;
      group = "users";
      mode = "0755";
    }
  ];

  systemd.tmpfiles.rules = [
    "d /projects/krita 0755 ${login} users -"
  ];
}
