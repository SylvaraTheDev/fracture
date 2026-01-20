{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Nushell - Modern shell
  # Uses Home Manager's programs.nushell module (idiomatic approach)

  home-manager.users.elyria =
    { config, pkgs, ... }:
    {
      programs.nushell = {
        enable = true;

        # Extra config appended to config.nu
        extraConfig = ''
          # Base config
          $env.config = {
            show_banner: false
            table: {
              mode: rounded
            }
          }

          # Editor config
          $env.EDITOR = "zed"
          $env.VISUAL = "zed"
        '';

        # Shell aliases (converted from functions/aliases.nu)
        shellAliases = {
          sudo = "run0";
          ls = "eza --icons --git";
          la = "eza --icons --git --all";
          ll = "eza --icons --git --long --all";
          tree = "eza --icons --git --tree";
          d = "docker";
          dc = "docker compose";
          k = "kubectl";
          t = "talosctl";
          o = "omnictl";
          deck = "deckmaster -deck ~/.config/deckmaster/main.deck";
        };
      };

      # Zoxide integration (idiomatic)
      programs.zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      # Required tools for aliases
      home.packages = with pkgs; [
        eza
        zoxide
      ];
    };
}
