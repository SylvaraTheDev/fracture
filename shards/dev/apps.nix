{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;
in
{
  home-manager.users.${login} = _: {
    home.packages = with pkgs; [
      adoptopenjdk-icedtea-web

      # Languages
      python3
      zig
      elixir
      erlang
      flutter
      nodejs_22

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

  };
}
