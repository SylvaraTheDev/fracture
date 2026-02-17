{
  config,
  ...
}:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    programs.zed-editor = {
      enable = true;
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
      ];
      userSettings = {
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

    home.persistence."/persist".directories = [
      ".local/share/zed"
    ];
  };
}
