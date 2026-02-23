{
  config,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;

  krita-ai-diffusion = pkgs.fetchzip {
    url = "https://github.com/Acly/krita-ai-diffusion/releases/download/v1.48.0/krita_ai_diffusion-1.48.0.zip";
    hash = "sha256-DMw/CPu7SqDsbb0h8tA2uEirG0DUEAd6YfYSpOnA1Mw=";
    stripRoot = false;
  };
in
{
  home-manager.users.${login} =
    { lib, ... }:
    {
      home.packages = with pkgs; [
        krita
      ];

      home.activation.linkKritaAiDiffusion = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p ~/.local/share/krita/pykrita
        ln -sfn "${krita-ai-diffusion}/ai_diffusion" ~/.local/share/krita/pykrita/ai_diffusion
        ln -sf "${krita-ai-diffusion}/ai_diffusion.desktop" ~/.local/share/krita/pykrita/ai_diffusion.desktop

        # Pre-enable the AI Diffusion plugin if not already configured
        KRITARC="$HOME/.config/kritarc"
        if [ ! -f "$KRITARC" ] || ! grep -q "enable_ai_diffusion" "$KRITARC"; then
          touch "$KRITARC"
          if ! grep -q '^\[python\]' "$KRITARC"; then
            printf '\n[python]\n' >> "$KRITARC"
          fi
          ${pkgs.gnused}/bin/sed -i '/^\[python\]/a enable_ai_diffusion=true' "$KRITARC"
        fi
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
