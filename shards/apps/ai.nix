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
        inputs.claude-o-meter.homeManagerModules.default
      ];

      # Claude-o-meter
      services.claude-o-meter = {
        enable = true;
        # debug = true;
      };
    };
}
