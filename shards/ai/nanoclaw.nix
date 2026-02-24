{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture) user;
  cfg = config.fracture.nanoclaw;
  secretsFile = config.fracture.secretsDir + "/api/nanoclaw.yaml";
in
{
  options.fracture.nanoclaw = {
    enable = lib.mkEnableOption "NanoClaw distributed AI assistant";

    sourceDir = lib.mkOption {
      type = lib.types.str;
      default = "/projects/repos/github.com/SylvaraTheDev/nanoclaw";
      description = "Path to local NanoClaw fork source.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/projects/nanoclaw";
      description = "Persistent runtime data directory.";
    };

    obsidianVault = lib.mkOption {
      type = lib.types.str;
      default = "sola";
      description = "Obsidian vault name to mount.";
    };

    channel = lib.mkOption {
      type = lib.types.enum [
        "discord"
        "whatsapp"
      ];
      default = "discord";
      description = "Messaging channel.";
    };

    maxConcurrentTasks = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Maximum concurrent task containers.";
    };

    taskTimeout = lib.mkOption {
      type = lib.types.int;
      default = 1800;
      description = "Task container timeout in seconds.";
    };

    namespaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "obsidian"
        "code"
        "research"
      ];
      description = "Allowed task DNS namespaces.";
    };

    images = {
      orchestrator = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io/sylvarathedev/nanoclaw-orchestrator:latest";
        description = "GHCR orchestrator image.";
      };

      task = lib.mkOption {
        type = lib.types.str;
        default = "ghcr.io/sylvarathedev/nanoclaw-task:latest";
        description = "GHCR task container image.";
      };
    };

    network.subnet = lib.mkOption {
      type = lib.types.str;
      default = "172.20.0.0/16";
      description = "Podman bridge network subnet.";
    };

    secrets.extraKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional SOPS secret key names.";
    };
  };

  config = lib.mkIf cfg.enable {
    # SOPS Secrets
    sops.secrets = {
      "nanoclaw/anthropic_api_key".sopsFile = secretsFile;
      "nanoclaw/discord_bot_token".sopsFile = secretsFile;
    }
    // lib.listToAttrs (
      map (k: lib.nameValuePair "nanoclaw/${k}" { sopsFile = secretsFile; }) cfg.secrets.extraKeys
    );

    # Podman Bridge Network
    systemd.services.nanoclaw-network = {
      description = "NanoClaw Podman bridge network";
      after = [ "podman.service" ];
      requires = [ "podman.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "nanoclaw-network-create" ''
          if ! ${pkgs.podman}/bin/podman network exists nanoclaw-net; then
            ${pkgs.podman}/bin/podman network create \
              --subnet ${cfg.network.subnet} \
              --driver bridge \
              nanoclaw-net
          fi
        '';
      };
    };

    # Image Pull Service (replaces local build)
    systemd.services.nanoclaw-pull = {
      description = "Pull NanoClaw container images from GHCR";
      after = [ "podman.service" ];
      requires = [ "podman.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        LoadCredential = [
          "ghcr_token:${config.sops.secrets.github-token.path}"
        ];
        ExecStart = pkgs.writeShellScript "nanoclaw-pull" ''
          ${pkgs.podman}/bin/podman login ghcr.io \
            -u SylvaraTheDev \
            --password-stdin < "$CREDENTIALS_DIRECTORY/ghcr_token"
          ${pkgs.podman}/bin/podman pull ${cfg.images.orchestrator}
          ${pkgs.podman}/bin/podman pull ${cfg.images.task}
        '';
      };
    };

    # OCI Orchestrator Container
    virtualisation.oci-containers = {
      backend = "podman";
      containers.nanoclaw = {
        image = cfg.images.orchestrator;
        volumes = [
          "${cfg.dataDir}:/app/data:rw"
          "${cfg.dataDir}/groups:/app/groups:rw"
          "${cfg.dataDir}/store:/app/store:rw"
          "/run/podman/podman.sock:/var/run/docker.sock:rw"
        ];
        extraOptions = [
          "--network=nanoclaw-net"
          "--network-alias=orchestrator.nanoclaw"
          "--label=nanoclaw.role=orchestrator"
        ];
      };
    };

    # Pass environment file to container
    virtualisation.oci-containers.containers.nanoclaw.environmentFiles = [ "/run/nanoclaw.env" ];

    # Systemd Service Overrides
    systemd.services.podman-nanoclaw = {
      after = [
        "nanoclaw-network.service"
        "nanoclaw-pull.service"
      ];
      requires = [
        "nanoclaw-network.service"
        "nanoclaw-pull.service"
      ];

      serviceConfig = {
        LoadCredential = [
          "anthropic_api_key:${config.sops.secrets."nanoclaw/anthropic_api_key".path}"
          "discord_bot_token:${config.sops.secrets."nanoclaw/discord_bot_token".path}"
        ]
        ++ map (k: "${k}:${config.sops.secrets."nanoclaw/${k}".path}") cfg.secrets.extraKeys;
      };

      preStart = ''
        mkdir -p ${cfg.dataDir}/workspace ${cfg.dataDir}/ipc ${cfg.dataDir}/groups ${cfg.dataDir}/store ${cfg.dataDir}/db

        # Read credentials from systemd credentials directory
        ANTHROPIC_KEY=$(cat "$CREDENTIALS_DIRECTORY/anthropic_api_key")
        DISCORD_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/discord_bot_token")

        # Build container environment file from secrets + config
        cat > /run/nanoclaw.env <<EOF
        ANTHROPIC_API_KEY=$ANTHROPIC_KEY
        NANOCLAW_DISCORD_TOKEN=$DISCORD_TOKEN
        CONTAINER_IMAGE=${cfg.images.task}
        MAX_CONCURRENT_CONTAINERS=${toString cfg.maxConcurrentTasks}
        CONTAINER_TIMEOUT=${toString (cfg.taskTimeout * 1000)}
        NANOCLAW_NETWORK=nanoclaw-net
        NANOCLAW_NAMESPACES=${lib.concatStringsSep "," cfg.namespaces}
        HOST_DATA_DIR=${cfg.dataDir}
        HOST_GROUPS_DIR=${cfg.dataDir}/groups
        HOST_PROJECT_ROOT=${cfg.sourceDir}
        EOF

        chmod 600 /run/nanoclaw.env
      '';
    };

    # Persistence
    environment.persistence."/persist-projects".directories = [
      {
        directory = "/projects/nanoclaw";
        user = user.login;
        group = "users";
        mode = "0755";
      }
    ];

    # tmpfiles
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 ${user.login} users -"
      "d ${cfg.dataDir}/workspace 0755 ${user.login} users -"
      "d ${cfg.dataDir}/ipc 0755 ${user.login} users -"
      "d ${cfg.dataDir}/groups 0755 ${user.login} users -"
      "d ${cfg.dataDir}/store 0755 ${user.login} users -"
      "d ${cfg.dataDir}/db 0755 ${user.login} users -"
    ];
  };
}
