{
  config,
  lib,
  ...
}:

let
  cfg = config.fracture.nanoclaw;
in
{
  options.fracture.nanoclaw = {
    enable = lib.mkEnableOption "NanoClaw AI assistant";
  };

  config = lib.mkIf cfg.enable {
    services.nanoclaw = {
      enable = true;
      dataDir = "/projects/nanoclaw";
      sourceDir = "/projects/repos/github.com/SylvaraTheDev/nanoclaw";
      namespaces = [
        "obsidian"
        "code"
        "research"
      ];
      secrets.sopsFile = config.fracture.secretsDir + "/api/nanoclaw.yaml";
      ghcr.tokenFile = config.sops.secrets.github-token.path;
    };

    # Impermanence: persist data across reboots
    environment.persistence."/persist-projects".directories = [
      {
        directory = "/projects/nanoclaw";
        user = config.fracture.user.login;
        group = "users";
        mode = "0755";
      }
    ];
  };
}
