#!/bin/bash

# ==============================================================================
#
# Alfred Wrapper for fc Commands
#
# DESCRIPTION:
#   This script provides the environment setup needed to run fc commands
#   from Alfred, which runs in a minimal shell environment without the
#   user's full shell configuration.
#
# USAGE:
#   ./fc-wrapper.sh <command> [args...]
#   ./fc-wrapper.sh wifi on
#   ./fc-wrapper.sh bluetooth status
#
# NOTES:
#   - The __DOTFILES_ROOT__ placeholder is replaced during installation
#   - This script sets up PATH to find Homebrew and fc tools
#
# ==============================================================================

# Set up PATH to find Homebrew and system utilities
# Check both Apple Silicon and Intel Homebrew locations
if [[ -d "/opt/homebrew/bin" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -d "/usr/local/bin" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# Standard system paths
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Dotfiles root - this placeholder is replaced during 'fc alfred install'
DOTFILES_ROOT="__DOTFILES_ROOT__"

# Fallback detection if placeholder wasn't replaced
if [[ "$DOTFILES_ROOT" == "__DOTFILES_ROOT__" ]]; then
    # Try common locations
    if [[ -d "$HOME/.dotfiles" ]]; then
        DOTFILES_ROOT="$HOME/.dotfiles"
    elif [[ -d "$HOME/dotfiles" ]]; then
        DOTFILES_ROOT="$HOME/dotfiles"
    else
        echo "Error: Could not find dotfiles directory"
        exit 1
    fi
fi

export DOTFILES_ROOT

# Add our bin directory to PATH
export PATH="$DOTFILES_ROOT/bin:$PATH"

# Execute the fc command with all arguments
exec "$DOTFILES_ROOT/bin/fc" "$@"
