{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture) user obsidian;
  cfg = config.fracture.nanoclaw;
  secretsFile = config.fracture.secretsDir + "/api/nanoclaw.yaml";
  vaultPath = "${obsidian.basePath}/${cfg.obsidianVault}";
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

    taskImage = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "nanoclaw-task";
        description = "Task container image name.";
      };

      tag = lib.mkOption {
        type = lib.types.str;
        default = "latest";
        description = "Task container image tag.";
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

    # Image Build Service
    systemd.services.nanoclaw-build = {
      description = "Build NanoClaw container images";
      after = [ "podman.service" ];
      requires = [ "podman.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = user.login;
        Group = "users";
        ExecStart = pkgs.writeShellScript "nanoclaw-build" ''
          cd ${cfg.sourceDir}
          ${pkgs.podman}/bin/podman build -t nanoclaw-orchestrator:latest -f container/Dockerfile .
          ${pkgs.podman}/bin/podman build -t ${cfg.taskImage.name}:${cfg.taskImage.tag} -f container/Dockerfile.task .
        '';
      };
    };

    # OCI Orchestrator Container
    virtualisation.oci-containers = {
      backend = "podman";
      containers.nanoclaw = {
        image = "nanoclaw-orchestrator:latest";
        volumes = [
          "${cfg.dataDir}:/app/data:rw"
          "${cfg.dataDir}/groups:/app/groups:rw"
          "${cfg.dataDir}/workspace:/workspace/global:rw"
          "${cfg.dataDir}/ipc:/workspace/ipc:rw"
          "${vaultPath}:${vaultPath}:rw"
          "/projects/repos:/workspace/repos:ro"
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
        "nanoclaw-build.service"
      ];
      requires = [
        "nanoclaw-network.service"
        "nanoclaw-build.service"
      ];

      serviceConfig = {
        LoadCredential = [
          "anthropic_api_key:${config.sops.secrets."nanoclaw/anthropic_api_key".path}"
          "discord_bot_token:${config.sops.secrets."nanoclaw/discord_bot_token".path}"
        ]
        ++ map (k: "${k}:${config.sops.secrets."nanoclaw/${k}".path}") cfg.secrets.extraKeys;
      };

      preStart = ''
        mkdir -p ${cfg.dataDir}/workspace ${cfg.dataDir}/ipc ${cfg.dataDir}/groups ${cfg.dataDir}/db

        # Read credentials from systemd credentials directory
        ANTHROPIC_KEY=$(cat "$CREDENTIALS_DIRECTORY/anthropic_api_key")
        DISCORD_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/discord_bot_token")

        # Build container environment file from secrets
        cat > /run/nanoclaw.env <<EOF
        ANTHROPIC_API_KEY=$ANTHROPIC_KEY
        NANOCLAW_DISCORD_TOKEN=$DISCORD_TOKEN
        CONTAINER_IMAGE=${cfg.taskImage.name}:${cfg.taskImage.tag}
        MAX_CONCURRENT_CONTAINERS=${toString cfg.maxConcurrentTasks}
        CONTAINER_TIMEOUT=${toString (cfg.taskTimeout * 1000)}
        NANOCLAW_NETWORK=nanoclaw-net
        NANOCLAW_NAMESPACES=${lib.concatStringsSep "," cfg.namespaces}
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
      "d ${cfg.dataDir}/db 0755 ${user.login} users -"
    ];
  };
}
