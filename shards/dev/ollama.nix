{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.persistence."/persist-projects".directories = [
    "/projects/ollama"
  ];

  systemd.tmpfiles.rules = [
    "d /projects/ollama 0777 root root -"
  ];

  services.ollama = {
    enable = true;
    package = lib.mkIf (config.fracture.gpu == "nvidia") pkgs.ollama-cuda;
    home = "/projects/ollama";
    models = "/projects/ollama/models";
    loadModels = [ "qwen3:8b" ];
    syncModels = true;
    environmentVariables = {
      OLLAMA_KEEP_ALIVE = "5m";
    };
  };
}
