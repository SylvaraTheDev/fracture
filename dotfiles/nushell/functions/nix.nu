# Rebuild NixOS
def --env rebuild [] {
  echo "Changing directory to ~/.config/nix"
  cd ~/.config/nix

  echo "Pulling git updates..."
  git pull

  echo "Authenticating run0 access..."

  echo "Running nixos-rebuild..."
  bash -c "run0 nixos-rebuild switch --flake .#forge --log-format internal-json 2>&1 | nom --json"
}

# Update flake
def --env upgrade [] {
  echo "Switching to ~/.config/nix"
  cd ~/.config/nix

  echo "Upgrading flake..."
  nix flake update
}

export def --env clean [arg?: string] {
  let help = [
    "Usage:"
    "  clean           # show help"
    "  clean +N        # Keep last N generations"
    ""
    "Example:"
    "  clean +10       # This keeps the last 10 generations"
  ]

  if ($arg | is-empty) or (not ($arg | str starts-with "+")) {
    $help | str join (char nl) | print
    return
  }

  let keep = (try {
    $arg | str trim | str replace '^\+' '' | into int
  } catch {
    -1
  })

  if $keep <= 0 {
    print $"Error: expected +N where N is a positive integer, got '($arg)'."
    print ""
    $help | str join (char nl) | print
    return (1)
  }

  let sys_profile = "/nix/var/nix/profiles/system"

  print $"Keeping last ($keep) generations for system profile..."
  bash -c $"run0 nix-env --profile ($sys_profile) --delete-generations +($keep)"

  print $"Keeping last ($keep) generations for current user profile..."
  bash -c $"nix-env --delete-generations +($keep)"

  print "Reclaiming store space (garbage collect)..."
  bash -c "run0 nix-store --gc"

  print "Done."
}
