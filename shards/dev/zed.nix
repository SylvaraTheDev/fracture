{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
  githubTokenPath = config.sops.secrets.github-token.path;

  # Wrapper that injects GITHUB_TOKEN from sops and forces NVIDIA Vulkan ICD
  zedWrapped = pkgs.writeShellScriptBin "zeditor" ''
    export GITHUB_TOKEN="$(cat "${githubTokenPath}")"
    export VK_ICD_FILENAMES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
    exec ${lib.getExe pkgs.zed-editor} "$@"
  '';
in
{
  # Make the sops secret readable by the user
  sops.secrets.github-token.owner = lib.mkForce login;

  home-manager.users.${login} = _: {
    programs.zed-editor = {
      enable = true;
      package = zedWrapped;
      extensions = [
        "nix"
        "elixir"
        "erlang"
        "go"
        "dart"
        "haskell"
        "python"
        "odin"
        "toml"
        "just"
        "docker-compose"
        "dockerfile"
        "make"
        "yaml"
        "kdl"
        "git-firefly"
        "material-icon-theme"
      ];
      userSettings = {
        icon_theme = "Material Icon Theme";
        buffer_font_features = {
          calt = true;
          liga = true;
        };
        autosave = "on_focus_change";
        format_on_save = "on";
        inlay_hints = {
          enabled = true;
        };
        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "nil"
            ];
            formatter = {
              external = {
                command = "nixfmt";
              };
            };
          };
        };
      };
    };

    home.sessionVariables = {
      EDITOR = "zeditor --wait";
      VISUAL = "zeditor --wait";
    };

    xdg.mimeApps.defaultApplications = {
      "text/plain" = [ "dev.zed.Zed.desktop" ];
      "text/x-csrc" = [ "dev.zed.Zed.desktop" ];
      "text/x-c++src" = [ "dev.zed.Zed.desktop" ];
      "text/x-chdr" = [ "dev.zed.Zed.desktop" ];
      "text/x-c++hdr" = [ "dev.zed.Zed.desktop" ];
      "text/x-python" = [ "dev.zed.Zed.desktop" ];
      "text/x-java" = [ "dev.zed.Zed.desktop" ];
      "text/x-makefile" = [ "dev.zed.Zed.desktop" ];
      "application/x-shellscript" = [ "dev.zed.Zed.desktop" ];
    };

    home.persistence."/persist".directories = [
      ".local/share/zed"
    ];
  };
}
