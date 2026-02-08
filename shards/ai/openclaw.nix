{ config, pkgs, ... }:

let
  inherit (config.fracture) user obsidian;
  secretsFile = config.fracture.secretsDir + "/api/openclaw.yaml";
  vaultPath = "${obsidian.basePath}/sola";

  openclawConfig = pkgs.writeText "openclaw.json" (
    builtins.toJSON {
      agents = {
        defaults = {
          model = {
            primary = "anthropic/claude-opus-4-5";
            fallbacks = [
              "anthropic/claude-sonnet-4.5"
              "anthropic/claude-haiku-4.5"
            ];
          };
          models = {
            "anthropic/claude-opus-4-5" = {
              alias = "opus";
            };
            "anthropic/claude-sonnet-4-5" = {
              alias = "sonnet";
            };
            "anthropic/claude-haiku-4-5" = {
              alias = "haiku";
            };
          };
        };
        list = [ { id = "main"; } ];
      };
      channels = {
        discord = {
          enabled = true;
          groupPolicy = "open";
        };
      };
      gateway = {
        mode = "local";
      };
    }
  );
in
{
  sops.secrets = {
    "openclaw/anthropic_api_key".sopsFile = secretsFile;
    "openclaw/discord_bot_token".sopsFile = secretsFile;
    "openclaw/brave_api_key".sopsFile = secretsFile;
    "openclaw/google_studio_api_key".sopsFile = secretsFile;
    "openclaw/gateway_token".sopsFile = secretsFile;
    "openclaw/moltbook_api_key".sopsFile = secretsFile;
    "openclaw/trello_api_key".sopsFile = secretsFile;
    "openclaw/trello_secret".sopsFile = secretsFile;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.openclaw = {
      image = "ghcr.io/openclaw/openclaw:latest";
      cmd = [
        "dist/index.js"
        "gateway"
        "--allow-unconfigured"
      ];
      ports = [ "18789:18789" ];
      volumes = [
        "/projects/openclaw:/home/node/.openclaw"
        "${vaultPath}:${vaultPath}:rw"
        "/projects/openclaw/obsidian-cli-bin:/opt/obsidian-cli:ro"
        "/home/${user.login}/.config/obsidian:/home/node/.config/obsidian:rw"
        "/projects/git/sylvara/fracture:/git/fracture:ro"
      ];
      extraOptions = [ "--network=host" ];
    };
  };

  systemd.services.podman-openclaw = {
    serviceConfig = {
      LoadCredential = [
        "anthropic_api_key:${config.sops.secrets."openclaw/anthropic_api_key".path}"
        "discord_bot_token:${config.sops.secrets."openclaw/discord_bot_token".path}"
        "brave_api_key:${config.sops.secrets."openclaw/brave_api_key".path}"
        "google_studio_api_key:${config.sops.secrets."openclaw/google_studio_api_key".path}"
        "gateway_token:${config.sops.secrets."openclaw/gateway_token".path}"
        "moltbook_api_key:${config.sops.secrets."openclaw/moltbook_api_key".path}"
        "trello_api_key:${config.sops.secrets."openclaw/trello_api_key".path}"
        "trello_secret:${config.sops.secrets."openclaw/trello_secret".path}"
      ];
    };

    preStart = ''
      mkdir -p /projects/openclaw /projects/openclaw/obsidian-cli-bin

      # Download obsidian-cli if not present
      if [ ! -f /projects/openclaw/obsidian-cli-bin/obsidian-cli ]; then
        ${pkgs.curl}/bin/curl -L \
          https://github.com/Yakitrak/obsidian-cli/releases/download/v0.2.2/obsidian-cli_0.2.2_linux_amd64.tar.gz \
          -o /tmp/obsidian-cli.tar.gz
        ${pkgs.gnutar}/bin/tar -xzf /tmp/obsidian-cli.tar.gz -C /projects/openclaw/obsidian-cli-bin
        chmod +x /projects/openclaw/obsidian-cli-bin/obsidian-cli
        rm /tmp/obsidian-cli.tar.gz
      fi

      # Inject secrets into openclaw config JSON
      DISCORD_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/discord_bot_token")
      GATEWAY_TOKEN=$(cat "$CREDENTIALS_DIRECTORY/gateway_token")

      ${pkgs.jq}/bin/jq \
        --arg dt "$DISCORD_TOKEN" \
        --arg gt "$GATEWAY_TOKEN" \
        '.channels.discord.token = $dt | .gateway.auth.token = $gt' \
        ${openclawConfig} > /projects/openclaw/openclaw.json

      chmod 644 /projects/openclaw/openclaw.json

      # Build container environment file from secrets
      ANTHROPIC_KEY=$(cat "$CREDENTIALS_DIRECTORY/anthropic_api_key")
      BRAVE_KEY=$(cat "$CREDENTIALS_DIRECTORY/brave_api_key")
      GOOGLE_KEY=$(cat "$CREDENTIALS_DIRECTORY/google_studio_api_key")

      cat > /run/openclaw.env <<EOF
      ANTHROPIC_API_KEY=$ANTHROPIC_KEY
      OPENCLAW_CHANNELS_DISCORD_TOKEN=$DISCORD_TOKEN
      BRAVE_API_KEY=$BRAVE_KEY
      GOOGLE_STUDIO_API_KEY=$GOOGLE_KEY
      OPENCLAW_WORKSPACE=/home/node/.openclaw/workspace
      PATH=/usr/local/bin:/usr/bin:/bin:/opt/obsidian-cli
      EOF

      # Write workspace credential files
      MOLTBOOK_KEY=$(cat "$CREDENTIALS_DIRECTORY/moltbook_api_key")
      TRELLO_KEY=$(cat "$CREDENTIALS_DIRECTORY/trello_api_key")
      TRELLO_SEC=$(cat "$CREDENTIALS_DIRECTORY/trello_secret")

      mkdir -p /projects/openclaw/workspace

      cat > /projects/openclaw/workspace/.moltbook-credentials <<EOF
      $MOLTBOOK_KEY
      EOF

      cat > /projects/openclaw/workspace/.trello-credentials <<EOF
      TRELLO_API_KEY=$TRELLO_KEY
      TRELLO_TOKEN=$TRELLO_SEC
      EOF

      chmod 600 /projects/openclaw/workspace/.moltbook-credentials
      chmod 600 /projects/openclaw/workspace/.trello-credentials
    '';
  };

  # Pass the env file to the container
  virtualisation.oci-containers.containers.openclaw.environmentFiles = [
    "/run/openclaw.env"
  ];
}
