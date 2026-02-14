{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;

  # MCP server definitions (merged into ~/.claude.json on activation)
  mcpServers = {
    github = {
      type = "http";
      url = "https://api.githubcopilot.com/mcp/";
    };
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
  home-manager.users.${login} =
    { lib, ... }:
    {
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

      # Global instructions, agents, and rules
      home.file.".claude/CLAUDE.md".source = dotfiles + "/claude/CLAUDE.md";
      home.file.".claude/agents" = {
        source = dotfiles + "/claude/agents";
        recursive = true;
      };
      home.file.".claude/rules" = {
        source = dotfiles + "/claude/rules";
        recursive = true;
      };

      # Merge MCP servers into ~/.claude.json (preserves runtime state)
      home.activation.claudeMcpServers = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        CLAUDE_JSON="$HOME/.claude.json"
        DESIRED_MCP='${builtins.toJSON mcpServers}'
        if [ -f "$CLAUDE_JSON" ]; then
          ${lib.getExe pkgs.jq} --argjson mcp "$DESIRED_MCP" '.mcpServers = $mcp' \
            "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
        else
          echo '{"mcpServers":'"$DESIRED_MCP"'}' > "$CLAUDE_JSON"
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
