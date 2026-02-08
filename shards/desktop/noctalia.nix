{
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  # Noctalia Shell - Desktop shell for Wayland
  # Uses Home Manager module for configuration

  # System-level dependencies for Noctalia
  environment.systemPackages = with pkgs; [
    # Core dependencies (required)
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default # Quickshell - core shell framework
    brightnessctl # Monitor brightness control
    git # Required for update checking and plugins

    # Optional but recommended
    cliphist # Clipboard history
    wlsunset # Night light
    cava # Audio visualizer
    python3 # Calendar events
    evolution-data-server # Calendar events
  ];

  home-manager.users.${login} =
    { ... }:
    {
      imports = [ inputs.noctalia.homeModules.default ];

      home.persistence."/persist".directories = [
        ".cache/cliphist"
      ];

      # Mako notification daemon config
      xdg.configFile."mako".source = ../../dotfiles/mako;

      programs.noctalia-shell = {
        enable = true;

        # Don't use systemd service - Niri spawn-at-startup handles this
        systemd.enable = false;

        settings = {
          # Bar configuration
          bar = {
            density = "normal";
            position = "top";
            showCapsule = true;
            widgets = {
              left = [
                {
                  id = "ControlCenter";
                  useDistroLogo = true;
                }
                { id = "Network"; }
                { id = "Bluetooth"; }
              ];
              center = [
                {
                  id = "Workspace";
                  hideUnoccupied = false;
                  labelMode = "none";
                }
              ];
              right = [
                {
                  id = "Battery";
                  alwaysShowPercentage = true;
                  warningThreshold = 30;
                }
                {
                  id = "Clock";
                  formatHorizontal = "HH:mm";
                  formatVertical = "HH mm";
                  useMonospacedFont = true;
                  usePrimaryColor = true;
                }
              ];
            };
          };

          # Color scheme
          colorSchemes.predefinedScheme = "Lavender";

          # General settings
          general = {
            radiusRatio = 0.3;
          };
        };
      };
    };
}
