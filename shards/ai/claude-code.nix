{ config, ... }:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
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

    # Global instructions and agent definitions for all workspaces
    home.file.".claude/CLAUDE.md".source = dotfiles + "/claude/CLAUDE.md";
    home.file.".claude/agents" = {
      source = dotfiles + "/claude/agents";
      recursive = true;
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
