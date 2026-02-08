{
  config,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  home-manager.users.${login} = _: {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo.source = "~/.config/fastfetch/images/nix.png";
        display.separator = " ";
        modules = [
          "break"
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}┌─────────────────────  OS Information  ─────────────────────┐{#}";
          }
          {
            type = "os";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "kernel";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "packages";
            key = "{#90}│{#} 󰏖";
            keyWidth = 6;
          }
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}└────────────────────────────────────────────────────────────┘{#}";
          }
          "break"
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}┌────────────────────  Shell & Terminal  ────────────────────┐{#}";
          }
          {
            type = "shell";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "terminal";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}└────────────────────────────────────────────────────────────┘{#}";
          }
          "break"
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}┌───────────────────  Desktop Environment  ──────────────────┐{#}";
          }
          {
            type = "wm";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}└────────────────────────────────────────────────────────────┘{#}";
          }
          "break"
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}┌────────────────────────  Hardware  ────────────────────────┐{#}";
          }
          {
            type = "cpu";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "gpu";
            key = "{#90}│{#} 󰍺";
            keyWidth = 6;
          }
          {
            type = "memory";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "disk";
            key = "{#90}│{#} ";
            keyWidth = 6;
          }
          {
            type = "title";
            keyWidth = 0;
            format = "{#90}└────────────────────────────────────────────────────────────┘{#}";
          }
          "break"
        ];
      };
    };

    home.file.".config/fastfetch/images" = {
      source = dotfiles + "/fastfetch/images";
      recursive = true;
      force = true;
    };
  };

  environment.systemPackages = with pkgs; [
    fastfetch
  ];
}
