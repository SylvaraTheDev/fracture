# Environment Config

# Redirect history to data dir (writeable) instead of config dir (read-only in Nix)
$env.config = {
  history: {
    file_format: "sqlite" 
    isolation: true
  }
}

# Ensure history path is in a writeable location
$env.NU_HISTORY_FILE = ($nu.data-home | path join "history.sqlite3")
