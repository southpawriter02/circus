# ==============================================================================
# PATH Management
#
# This file consolidates all PATH additions into a single location.
# Order matters: later entries in PATH take precedence for commands.
#
# USAGE:
#   path_prepend "/some/path"  - Add to front of PATH (highest priority)
#   path_append "/some/path"   - Add to end of PATH (lowest priority)
#
# ==============================================================================

# --- Helper Functions ---------------------------------------------------------

# Add directory to the FRONT of PATH (highest priority)
# Only adds if directory exists and isn't already in PATH
path_prepend() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

# Add directory to the END of PATH (lowest priority)
# Only adds if directory exists and isn't already in PATH
path_append() {
    [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$PATH:$1"
}

# --- User Binaries (Highest Priority) ----------------------------------------

# Personal scripts and binaries
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# --- Language-Specific Paths --------------------------------------------------

# Go
path_prepend "$HOME/go/bin"

# Rust (Cargo)
path_prepend "$HOME/.cargo/bin"

# Python (pyenv)
[[ -d "$HOME/.pyenv/bin" ]] && path_prepend "$HOME/.pyenv/bin"
[[ -d "$HOME/.pyenv/shims" ]] && path_prepend "$HOME/.pyenv/shims"

# Ruby (rbenv)
[[ -d "$HOME/.rbenv/bin" ]] && path_prepend "$HOME/.rbenv/bin"
[[ -d "$HOME/.rbenv/shims" ]] && path_prepend "$HOME/.rbenv/shims"

# Node.js (npm global)
[[ -d "$HOME/.npm-global/bin" ]] && path_append "$HOME/.npm-global/bin"

# pnpm
[[ -d "$HOME/.local/share/pnpm" ]] && path_append "$HOME/.local/share/pnpm"

# --- Tool-Specific Paths ------------------------------------------------------

# VS Code CLI
path_append "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# Rancher Desktop
path_append "$HOME/.rd/bin"

# MySQL/MariaDB (Homebrew)
[[ -d "/opt/homebrew/opt/mysql-client/bin" ]] && path_append "/opt/homebrew/opt/mysql-client/bin"

# PostgreSQL (Homebrew)
[[ -d "/opt/homebrew/opt/postgresql@16/bin" ]] && path_append "/opt/homebrew/opt/postgresql@16/bin"
[[ -d "/opt/homebrew/opt/postgresql@15/bin" ]] && path_append "/opt/homebrew/opt/postgresql@15/bin"

# GNU coreutils (if installed via Homebrew, use g-prefixed by default)
# Uncomment to override macOS commands with GNU versions:
# [[ -d "/opt/homebrew/opt/coreutils/libexec/gnubin" ]] && path_prepend "/opt/homebrew/opt/coreutils/libexec/gnubin"

# --- Export -------------------------------------------------------------------

export PATH
