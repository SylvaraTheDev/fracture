{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
  dotfiles = config.fracture.dotfilesDir;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      # Editors
      zed-editor
      adoptopenjdk-icedtea-web

      # Languages
      zig
      elixir
      erlang
      flutter

      # Nix tools
      nil
      nixd
      nixdoc
      nixfmt
      nh
      nix-output-monitor
      deadnix
      statix
      alejandra
      nix-tree

      # Build tools
      just
      gnumake
      pre-commit
      devenv
      meson

      # Package managers
      uv
      pnpm

      # Git extras
      git-credential-manager
      onefetch
      gource
    ];

    home.file.".config/zed" = {
      source = dotfiles + "/zed";
      recursive = true;
      force = true;
    };
  };
}
