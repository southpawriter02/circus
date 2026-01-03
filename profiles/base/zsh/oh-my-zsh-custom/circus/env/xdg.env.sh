# ==============================================================================
# XDG Base Directory Specification
#
# Standard directories for configuration, data, cache, and runtime files.
# Many modern tools respect these variables to keep $HOME clean.
#
# REFERENCES:
#   - https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
#   - https://wiki.archlinux.org/title/XDG_Base_Directory
# ==============================================================================

# --- Configuration Files ------------------------------------------------------

# User-specific configuration files (settings, preferences)
# Similar to: /etc on system-level
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# --- Data Files ---------------------------------------------------------------

# User-specific data files (databases, persistent state)
# Similar to: /usr/share on system-level
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# --- Cache Files --------------------------------------------------------------

# User-specific cache files (safe to delete)
# Similar to: /var/cache on system-level
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- State Files --------------------------------------------------------------

# User-specific state files (logs, history - persists between restarts)
# Similar to: /var/lib on system-level
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# --- Runtime Files ------------------------------------------------------------

# User-specific runtime files (sockets, named pipes - cleared on reboot)
# Similar to: /run on system-level
# macOS doesn't have /run, so we use /tmp
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-$(id -u)}"

# --- Create Directories -------------------------------------------------------

# Create directories if they don't exist
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"

# Runtime directory needs special permissions (700)
if [[ ! -d "$XDG_RUNTIME_DIR" ]]; then
    mkdir -p "$XDG_RUNTIME_DIR"
    chmod 700 "$XDG_RUNTIME_DIR"
fi

# ==============================================================================
# Tools That Respect XDG
#
# Many tools will automatically use these directories:
# - bat, fd, ripgrep
# - cargo, rustup
# - npm, yarn, pnpm
# - docker, kubectl
# - less (with LESSHISTFILE)
# - zsh (with HISTFILE)
#
# Some tools need explicit configuration:
# - wget: WGETRC=$XDG_CONFIG_HOME/wget/wgetrc
# - npm: NPM_CONFIG_USERCONFIG=$XDG_CONFIG_HOME/npm/npmrc
# ==============================================================================
