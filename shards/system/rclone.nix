{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.fracture.rclone;
  secretsFile = config.fracture.secretsDir + "/api/backblaze.yaml";
in
{
  options.fracture.rclone.b2.jobs = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "Local path to sync from.";
          };

          bucket = lib.mkOption {
            type = lib.types.str;
            description = "B2 bucket name.";
          };

          dest = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Destination prefix within the bucket.";
          };

          schedule = lib.mkOption {
            type = lib.types.str;
            default = "*-*-* 00/6:00:00";
            description = "systemd OnCalendar schedule expression.";
          };

          excludes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "Rclone exclude patterns.";
          };
        };
      }
    );
    default = { };
    description = "Backblaze B2 rclone sync jobs.";
  };

  config = lib.mkIf (cfg.b2.jobs != { }) {
    sops.secrets."backblaze/key_id".sopsFile = secretsFile;
    sops.secrets."backblaze/application_key".sopsFile = secretsFile;

    environment.systemPackages = [ pkgs.rclone ];

    systemd.services = lib.mapAttrs' (
      name: job:
      lib.nameValuePair "rclone-b2-${name}" {
        description = "Rclone sync ${name} to Backblaze B2";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Type = "oneshot";
          ExecStart =
            let
              excludeFlags = lib.concatMapStringsSep " " (e: "--exclude '${e}'") job.excludes;
              dest = if job.dest != "" then "${job.bucket}/${job.dest}" else job.bucket;
              script = pkgs.writeShellScript "rclone-b2-${name}" ''
                KEY_ID=$(cat ${config.sops.secrets."backblaze/key_id".path})
                APP_KEY=$(cat ${config.sops.secrets."backblaze/application_key".path})

                export RCLONE_CONFIG=/dev/null

                ${pkgs.rclone}/bin/rclone sync \
                  "${job.source}" \
                  ":b2:${dest}" \
                  --b2-account "$KEY_ID" \
                  --b2-key "$APP_KEY" \
                  --transfers 8 \
                  --fast-list \
                  ${excludeFlags} \
                  --log-level INFO
              '';
            in
            "${script}";
        };
      }
    ) cfg.b2.jobs;

    systemd.timers = lib.mapAttrs' (
      name: job:
      lib.nameValuePair "rclone-b2-${name}" {
        description = "Timer for rclone B2 sync: ${name}";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = job.schedule;
          Persistent = true;
          RandomizedDelaySec = "15m";
        };
      }
    ) cfg.b2.jobs;
  };
}
