# Rebuild NixOS
def --env rebuild [] {
  echo "Changing directory to /projects/repos/github.com/fracture"
  cd /projects/repos/github.com/fracture

  echo "Pulling git updates..."
  git pull

  echo "Running safety checks..."
  just check

  echo "Running nixos-rebuild..."
  bash -c "run0 nixos-rebuild switch --flake .#fracture --log-format internal-json 2>&1 | nom --json"
}

# Update flake
def --env upgrade [] {
  echo "Switching to /projects/repos/github.com/fracture"
  cd /projects/repos/github.com/fracture

  echo "Upgrading flake..."
  nix flake update
}

# Drop into a devenv shell
def dev [shell?: string] {
  let flake = "/projects/repos/github.com/fracture"
  let available = ["dart" "elixir" "go" "kubernetes" "nix" "packaging" "python"]

  if ($shell | is-empty) {
    print "Usage: dev <shell>"
    print ""
    print "Available shells:"
    $available | each { |s| print $"  ($s)" }
    return
  }

  if $shell not-in $available {
    print $"Unknown shell '($shell)'"
    print ""
    print "Available shells:"
    $available | each { |s| print $"  ($s)" }
    return
  }

  nix develop $"($flake)#($shell)" --no-pure-eval
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
