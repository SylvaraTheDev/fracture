# This is the global file to hold all Nushell aliases

# Modern file tools
alias ls = eza --icons --git
alias la = eza --icons --git --all
alias ll = eza --icons --git --long --all
alias tree = eza --icons --git --tree

# Docker
alias d = docker
alias dc = docker compose

# Kubernetes
alias k = kubectl
alias t = talosctl
alias o = omnictl

# Deckmaster
alias deck = deckmaster -deck ~/.config/deckmaster/main.deck
