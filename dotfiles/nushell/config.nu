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

# Custom functions
source ~/.config/nushell/functions/nix.nu
source ~/.config/nushell/functions/aliases.nu
