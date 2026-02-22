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
  hfSecretsFile = config.fracture.secretsDir + "/api/huggingface.yaml";
  civitaiSecretsFile = config.fracture.secretsDir + "/api/civitai.yaml";

  # Declarative model manifest — download checked/skipped per file on each boot
  models = {
    # Flux.1-dev bf16 (24GB — one-time NF4 conversion via ComfyUI, then use baked file)
    "checkpoints/flux1-dev.safetensors" = {
      url = "https://huggingface.co/black-forest-labs/FLUX.1-dev/resolve/main/flux1-dev.safetensors";
      gated = true;
    };

    # Text encoders
    "clip/clip_l.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/clip_l.safetensors";
    };
    "clip/t5xxl_fp8_e4m3fn.safetensors" = {
      url = "https://huggingface.co/comfyanonymous/flux_text_encoders/resolve/main/t5xxl_fp8_e4m3fn.safetensors";
    };
    "text_encoders/qwen_3_4b.safetensors" = {
      url = "https://huggingface.co/Comfy-Org/z_image/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors";
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
    "controlnet/Z-Image-Turbo-Fun-Controlnet-Union-2.1-2601-8steps.safetensors" = {
      url = "https://huggingface.co/alibaba-pai/Z-Image-Turbo-Fun-Controlnet-Union-2.1";
    };

    # Upscaler
    "upscale_models/RealESRGAN_x4plus.pth" = {
      url = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth";
    };

    # Diffusion models — Z-Image (GLM-Image)
    "diffusion_models/z_image_bf16.safetensors" = {
      url = "https://huggingface.co/Comfy-Org/z_image/resolve/main/split_files/diffusion_models/z_image_bf16.safetensors";
    };
    "diffusion_models/z_image_turbo_bf16.safetensors" = {
      url = "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors";
    };

    # SDXL checkpoints
    "checkpoints/ponyDiffusionV6XL_v6.safetensors" = {
      url = "https://civitai.com/api/download/models/290640";
      civitai = true;
    };
    "checkpoints/illustriousXL_v01.safetensors" = {
      url = "https://civitai.com/api/download/models/889818";
      civitai = true;
    };

    # LoRAs — anime style
    "loras/madbear-anime-flux.safetensors" = {
      url = "https://civitai.com/api/download/models/761857";
      civitai = true;
    };
    "loras/flat-colour-anime-v3.4.safetensors" = {
      url = "https://civitai.com/api/download/models/838667";
      civitai = true;
    };
  };

  aria2 = lib.getExe pkgs.aria2;
  hfCli = lib.getExe' pkgs.python3Packages.huggingface-hub "huggingface-cli";

  # Full HuggingFace repos — downloaded via huggingface-cli
  repos = {
    "HunyuanImage-3-NF4" = {
      repo = "EricRollei/HunyuanImage-3-NF4-ComfyUI";
    };
  };

  downloadScript = pkgs.writeShellScript "comfyui-model-download" ''
    set -uo pipefail

    MODELS_DIR="${modelsDir}"
    HF_TOKEN=""
    CIVITAI_TOKEN=""
    FAILED=0

    if [ -n "''${CREDENTIALS_DIRECTORY:-}" ]; then
      [ -f "$CREDENTIALS_DIRECTORY/hf_token" ] && HF_TOKEN=$(< "$CREDENTIALS_DIRECTORY/hf_token")
      [ -f "$CREDENTIALS_DIRECTORY/civitai_token" ] && CIVITAI_TOKEN=$(< "$CREDENTIALS_DIRECTORY/civitai_token")
    fi

    download_model() {
      local dest="$1"
      local url="$2"
      local gated="''${3:-false}"
      local civitai="''${4:-false}"
      local full_path="$MODELS_DIR/$dest"

      if [ -f "$full_path" ]; then
        return 0
      fi

      if [ "$gated" = "true" ] && [ -z "$HF_TOKEN" ]; then
        echo "Skipping gated model (no HF token in sops): $dest"
        return 0
      fi
      if [ "$civitai" = "true" ] && [ -z "$CIVITAI_TOKEN" ]; then
        echo "Skipping CivitAI model (no API key in sops): $dest"
        return 0
      fi

      mkdir -p "$(dirname "$full_path")"
      echo "Downloading: $dest"

      local aria2_args=(--split=8 --max-connection-per-server=8 --min-split-size=10M)
      aria2_args+=(--retry-wait=5 --max-tries=3 --connect-timeout=30)
      aria2_args+=(--dir="$(dirname "$full_path")" --out="$(basename "$full_path").tmp")
      if [ "$gated" = "true" ]; then
        aria2_args+=(--header="Authorization: Bearer $HF_TOKEN")
      fi
      if [ "$civitai" = "true" ]; then
        url="$url?token=$CIVITAI_TOKEN"
      fi

      if ${aria2} "''${aria2_args[@]}" "$url"; then
        mv "$full_path.tmp" "$full_path"
        echo "Complete: $dest"
      else
        echo "FAILED: $dest"
        rm -f "$full_path.tmp"
        FAILED=$((FAILED + 1))
      fi
    }

    download_repo() {
      local dest="$1"
      local repo="$2"
      local full_path="$MODELS_DIR/$dest"

      if [ -f "$full_path/.download-complete" ]; then
        return 0
      fi

      mkdir -p "$full_path"
      echo "Downloading repo: $repo → $dest"

      local hf_args=(download "$repo" --local-dir "$full_path")
      if [ -n "$HF_TOKEN" ]; then
        hf_args+=(--token "$HF_TOKEN")
      fi

      if ${hfCli} "''${hf_args[@]}"; then
        touch "$full_path/.download-complete"
        echo "Complete: $dest"
      else
        echo "FAILED: $dest"
        FAILED=$((FAILED + 1))
      fi
    }

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        dest: spec:
        "download_model ${lib.escapeShellArg dest} ${lib.escapeShellArg spec.url} ${
          lib.escapeShellArg (lib.boolToString (spec.gated or false))
        } ${lib.escapeShellArg (lib.boolToString (spec.civitai or false))}"
      ) models
    )}

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        dest: spec: "download_repo ${lib.escapeShellArg dest} ${lib.escapeShellArg spec.repo}"
      ) repos
    )}

    if [ "$FAILED" -gt 0 ]; then
      echo "$FAILED model(s) failed to download"
      exit 1
    fi
  '';
in
{
  sops.secrets.huggingface-read-only-key.sopsFile = hfSecretsFile;
  sops.secrets.civitai-key.sopsFile = civitaiSecretsFile;

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
    gpuSupport =
      if config.fracture.gpu == "nvidia" then
        "cuda"
      else if config.fracture.gpu == "amd" then
        "rocm"
      else
        "none";
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
      Comfy_HunyuanImage3 = pkgs.fetchFromGitHub {
        owner = "EricRollei";
        repo = "Comfy_HunyuanImage3";
        rev = "e1caeb72f7dd445286c722e97d6c702d35fe7977";
        hash = "sha256-k5UCxudwRX31ALZo/b2q5plV6pUTPnBaUXIklpK99rU=";
      };
      # Override bundled NF4 plugin with silveroxides fork (adds UNETLoaderNF4)
      ComfyUI_bitsandbytes_NF4 = pkgs.fetchFromGitHub {
        owner = "silveroxides";
        repo = "ComfyUI_bitsandbytes_NF4";
        rev = "dd2f774a2d3930de06fddc995901c830fc936715";
        hash = "sha256-f0PAK2J/qa3cSU+hCIbyhQvH01aAAcpeIlpmJ8iSOw4=";
      };
    };
  };

  # Contain ComfyUI memory: 20G RAM + 20G swap = 40G budget
  # Normal ops use ~12G, conversion workflow peaks ~28G (spills to swap)
  systemd.services.comfyui.serviceConfig = {
    MemoryHigh = "16G";
    MemoryMax = "20G";
    MemorySwapMax = "20G";
    OOMScoreAdjust = 500;
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
        "civitai_token:${config.sops.secrets.civitai-key.path}"
      ];
      ExecStart = downloadScript;
    };
  };
}
