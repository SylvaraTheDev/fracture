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

  # PreToolUse: block destructive git/shell operations (exit 2 = block)
  dangerCheckHook = pkgs.writeShellScript "claude-danger-check" ''
    cmd=$(${lib.getExe pkgs.jq} -r '.tool_input.command // empty')
    if echo "$cmd" | ${pkgs.gnugrep}/bin/grep -qE \
      'git\s+push\s+.*(-f|--force)|git\s+reset\s+--hard|--no-verify|git\s+(checkout|restore)\s+\.|git\s+clean\s+-[a-zA-Z]*f|git\s+branch\s+-D'; then
      echo "Blocked: destructive operation. Ask the user for confirmation." >&2
      exit 2
    fi
  '';

  # Stop: evaluate NixOS config before Claude finishes (fracture repo only)
  stopCheckHook = pkgs.writeShellScript "claude-stop-check" ''
    root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)" || exit 0
    [[ "$root" == */fracture ]] || exit 0
    cd "$root"
    ${pkgs.nix}/bin/nix eval .#nixosConfigurations.fracture.config.system.build.toplevel --apply '_: "ok"' 2>&1
  '';

  # PreCompact: inject critical context before summarisation
  preCompactHook = pkgs.writeShellScript "claude-precompact-hook" ''
    cat <<'CONTEXT'
    CRITICAL PROJECT CONTEXT:
    - NixOS config repo using flake-parts architecture
    - Custom options: fracture.* (defined in shards/options.nix)
    - Shards auto-discovered from shards/ (excluding shells/)
    - Build: just check | Format: nix fmt | Validate: nix flake check
    - Secrets via sops-nix, never plaintext
    - Root is ephemeral (impermanence), persist to /persist
    CONTEXT
  '';

  # Wrapper reads sops-rendered token at invocation time, execs github-mcp-server
  githubMcpWrapper = pkgs.writeShellScript "github-mcp" ''
    export GITHUB_PERSONAL_ACCESS_TOKEN="$(cat "${githubAuthPath}")"
    exec ${lib.getExe pkgs.github-mcp-server} stdio
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

  home-manager.users.${login} = _: {
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
        github = {
          type = "stdio";
          command = toString githubMcpWrapper;
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
          CLAUDE_CODE_EFFORT_LEVEL = "high";
          ENABLE_TOOL_SEARCH = "1";
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
          PreToolUse = [
            {
              matcher = "Bash";
              hooks = [
                {
                  type = "command";
                  command = toString dangerCheckHook;
                }
              ];
            }
          ];
          Stop = [
            {
              matcher = "";
              hooks = [
                {
                  type = "command";
                  command = toString stopCheckHook;
                }
              ];
            }
          ];
          PreCompact = [
            {
              matcher = "";
              hooks = [
                {
                  type = "command";
                  command = toString preCompactHook;
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
