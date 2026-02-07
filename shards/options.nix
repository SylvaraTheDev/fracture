{ lib, ... }:

{
  options.fracture = {
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "System hostname.";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      description = "NixOS and Home Manager state version.";
    };

    user = {
      login = lib.mkOption {
        type = lib.types.str;
        description = "Primary user login name.";
      };

      name = lib.mkOption {
        type = lib.types.str;
        description = "Primary user display name.";
      };

      git = {
        name = lib.mkOption {
          type = lib.types.str;
          description = "Git author name.";
        };

        email = lib.mkOption {
          type = lib.types.str;
          description = "Git author email.";
        };
      };

      groups = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "networkmanager"
          "wheel"
          "video"
          "input"
        ];
        description = "Extra groups for the primary user.";
      };
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "System timezone.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "System locale.";
    };

    gpu = lib.mkOption {
      type = lib.types.enum [
        "nvidia"
        "amd"
        "intel"
        "none"
      ];
      default = "none";
      description = "GPU driver to configure.";
    };

    vm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether this configuration is running in a VM.";
      };

      waylandDisplay = lib.mkOption {
        type = lib.types.str;
        default = "wayland-1";
        description = "Wayland display name for VM session sync.";
      };
    };
  };
}
