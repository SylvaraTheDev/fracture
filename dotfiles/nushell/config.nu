# Base config
$env.config = {
  show_banner: false
  table: {
    mode: rounded
  }
}

# Editor config
$env.EDITOR = "zed"
$env.VISUAL = "zed"

# nh (NixOS helper) — use run0 for privilege escalation
$env.NH_ELEVATION_PROGRAM = "run0"

# Custom functions
source ~/.config/nushell/functions/nix.nu
source ~/.config/nushell/functions/aliases.nu
