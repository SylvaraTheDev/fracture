{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.ollama = {
    enable = true;
    package = lib.mkIf (config.fracture.gpu == "nvidia") pkgs.ollama-cuda;
    loadModels = [ "qwen3:8b" ];
    syncModels = true;
    environmentVariables = {
      OLLAMA_MODELS = "/projects/ollama/models";
      OLLAMA_KEEP_ALIVE = "5m";
    };
  };
}
