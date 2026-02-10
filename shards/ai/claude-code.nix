{ config, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.claude-code = {
      enable = true;
      settings = {
        env = {
          ANTHROPIC_MODEL = "claude-opus-4-6";
          CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS = "1";
        };
        projects = {
          "/projects/repos" = {
            hasTrustDialogAccepted = true;
          };
        };
      };
    };

    home.persistence."/persist" = {
      directories = [
        ".claude"
        ".config/claude-code"
      ];
      files = [
        ".claude.json"
      ];
    };
  };
}
