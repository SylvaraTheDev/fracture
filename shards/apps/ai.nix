{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Local AI (System)
  services.ollama.enable = true;

  home-manager.users.elyria =
    { pkgs, ... }:
    {
      imports = [
        inputs.vicinae.homeManagerModules.default
        inputs.claude-o-meter.homeManagerModules.default
      ];

      # Vicinae
      services.vicinae.enable = true;
      home.packages = [
        inputs.vicinae.packages.x86_64-linux.default
        # pkgs.codex pkgs.antigravity # Validation pending
      ];

      # Claude-o-meter
      services.claude-o-meter = {
        enable = true;
        # debug = true;
      };
    };
}
