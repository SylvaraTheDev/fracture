{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
  dataDir = "/projects/comfyui";
  modelsDir = "${dataDir}/models";
  secretsFile = config.fracture.secretsDir + "/api/huggingface.yaml";

  # Declarative model manifest — download checked/skipped per file on each boot
  models = {
    # Flux.1-dev GGUF (Q5_K_S quantised — fits 16GB VRAM)
    "diffusion_models/flux1-dev-Q5_K_S.gguf" = {
      url = "https://huggingface.co/city96/FLUX.1-dev-gguf/resolve/main/flux1-dev-Q5_K_S.gguf";
    };

    # Text encoders
    "clip/clip_l.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors";
    };
    "clip/t5xxl_fp8_e4m3fn.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors";
    };

    # VAE (gated — requires HF token via sops)
    "vae/ae.safetensors" = {
      url = "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/ae.safetensors";
      gated = true;
    };

    # ControlNet
    "controlnet/flux-canny-controlnet-v3.safetensors" = {
      url = "https://huggingface.co/XLabs-AI/flux-controlnet-collections/resolve/main/flux-canny-controlnet-v3.safetensors";
    };
    "controlnet/flux-depth-controlnet-v3.safetensors" = {
      url = "https://huggingface.co/XLabs-AI/flux-controlnet-collections/resolve/main/flux-depth-controlnet-v3.safetensors";
    };

    # Upscaler
    "upscale_models/RealESRGAN_x4plus.pth" = {
      url = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth";
    };
  };

  downloadScript = pkgs.writeShellScript "comfyui-model-download" ''
    set -uo pipefail

    MODELS_DIR="${modelsDir}"
    HF_TOKEN=""
    FAILED=0

    if [ -n "''${CREDENTIALS_DIRECTORY:-}" ] && [ -f "$CREDENTIALS_DIRECTORY/hf_token" ]; then
      HF_TOKEN=$(< "$CREDENTIALS_DIRECTORY/hf_token")
    fi

    download_model() {
      local dest="$1"
      local url="$2"
      local gated="''${3:-false}"
      local full_path="$MODELS_DIR/$dest"

      if [ -f "$full_path" ]; then
        return 0
      fi

      if [ "$gated" = "true" ] && [ -z "$HF_TOKEN" ]; then
        echo "Skipping gated model (no HF token in sops): $dest"
        return 0
      fi

      mkdir -p "$(dirname "$full_path")"
      echo "Downloading: $dest"

      local curl_args=(-L --fail --retry 3 --connect-timeout 30 -o "$full_path.tmp")
      if [ "$gated" = "true" ]; then
        curl_args+=(--header "Authorization: Bearer $HF_TOKEN")
      fi

      if ${lib.getExe pkgs.curl} "''${curl_args[@]}" "$url"; then
        mv "$full_path.tmp" "$full_path"
        echo "Complete: $dest"
      else
        echo "FAILED: $dest"
        rm -f "$full_path.tmp"
        FAILED=$((FAILED + 1))
      fi
    }

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        dest: spec:
        "download_model ${lib.escapeShellArg dest} ${lib.escapeShellArg spec.url} ${
          lib.escapeShellArg (lib.boolToString (spec.gated or false))
        }"
      ) models
    )}

    if [ "$FAILED" -gt 0 ]; then
      echo "$FAILED model(s) failed to download"
      exit 1
    fi
  '';
in
{
  sops.secrets.huggingface-read-only-key.sopsFile = secretsFile;

  environment.persistence."/persist-projects".directories = [
    {
      directory = "/projects/comfyui";
      user = login;
      group = "users";
      mode = "0755";
    }
  ];

  systemd.tmpfiles.rules = [
    "d /projects/comfyui 0755 ${login} users -"
  ];

  services.comfyui = {
    enable = true;
    cuda = config.fracture.gpu == "nvidia";
    enableManager = true;
    inherit dataDir;
    user = login;
    group = "users";
    createUser = false;
    port = 8188;
    listenAddress = "127.0.0.1";
    customNodes = {
      comfy-pilot = pkgs.fetchFromGitHub {
        owner = "ConstantineB6";
        repo = "comfy-pilot";
        rev = "v1.0.24";
        hash = "sha256-l7sU0LUK+kzb4sBBh+YpKRQMjnKGDWtoxBG48mI9KCw=";
      };
    };
  };

  systemd.services.comfyui-models = {
    description = "Download ComfyUI models";
    after = [
      "comfyui.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      User = login;
      Group = "users";
      LoadCredential = [
        "hf_token:${config.sops.secrets.huggingface-read-only-key.path}"
      ];
      ExecStart = downloadScript;
    };
  };
}
