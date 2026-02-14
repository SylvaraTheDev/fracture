{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;

  # Path to sops-rendered GitHub token (user-readable at runtime)
  githubAuthPath = config.sops.templates."claude-github-auth".path;

  # Hook scripts (full nix store paths avoid PATH issues)
  nixfmtHook = pkgs.writeShellScript "claude-nixfmt-hook" ''
    fp=$(${lib.getExe pkgs.jq} -r '.tool_input.file_path // empty')
    if [[ "$fp" == *.nix ]]; then
      ${lib.getExe pkgs.nixfmt} "$fp" 2>/dev/null || true
    fi
  '';

  notifyHook = pkgs.writeShellScript "claude-notify-hook" ''
    ${pkgs.libnotify}/bin/notify-send "Claude Code" "Needs your attention"
  '';

  compactHook = pkgs.writeShellScript "claude-compact-hook" ''
    echo "Build: just check | Format: nix fmt | Validate: nix flake check"
  '';
in
{
  # Render GitHub PAT into a user-readable file for Claude MCP auth
  sops.templates."claude-github-auth" = {
    content = config.sops.placeholder.github-token;
    owner = login;
    group = "users";
    mode = "0400";
  };

  home-manager.users.${login} =
    { lib, ... }:
    {
      programs.claude-code = {
        enable = true;

        # MCP servers (wraps claude binary with --mcp-config)
        mcpServers = {
          context7 = {
            type = "http";
            url = "https://mcp.context7.com/mcp";
          };
          nixos = {
            type = "stdio";
            command = "nix";
            args = [
              "run"
              "github:utensils/mcp-nixos"
              "--"
            ];
          };
          "sequential-thinking" = {
            type = "stdio";
            command = "${pkgs.nodejs_22}/bin/npx";
            args = [
              "-y"
              "@modelcontextprotocol/server-sequential-thinking"
            ];
          };
        };

        # Global instructions
        memory.source = dotfiles + "/claude/CLAUDE.md";
        agentsDir = dotfiles + "/claude/agents";
        rulesDir = dotfiles + "/claude/rules";

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
          hooks = {
            PostToolUse = [
              {
                matcher = "Edit|Write";
                hooks = [
                  {
                    type = "command";
                    command = toString nixfmtHook;
                  }
                ];
              }
            ];
            Notification = [
              {
                matcher = "";
                hooks = [
                  {
                    type = "command";
                    command = toString notifyHook;
                  }
                ];
              }
            ];
            SessionStart = [
              {
                matcher = "compact";
                hooks = [
                  {
                    type = "command";
                    command = toString compactHook;
                  }
                ];
              }
            ];
          };
        };
      };

      home.activation.injectGithubMcpAuth = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -f "${githubAuthPath}" ] && [ -f "$HOME/.claude.json" ]; then
          token=$(cat "${githubAuthPath}")
          ${lib.getExe pkgs.jq} \
            --arg token "Bearer $token" \
            '.mcpServers.github = {"type":"http","url":"https://api.githubcopilot.com/mcp/","headers":{"Authorization":$token}}' \
            "$HOME/.claude.json" > "$HOME/.claude.json.tmp" \
            && mv "$HOME/.claude.json.tmp" "$HOME/.claude.json"
        fi
      '';

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
