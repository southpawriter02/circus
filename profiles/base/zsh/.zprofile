#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zprofile
#
# DESCRIPTION:  This file is sourced for login shells, after .zshenv. It is
#               the Zsh equivalent of the standard .profile and is the ideal
#               place to run commands that should only be executed at login.
#
# ==============================================================================

#
# Source the generic, POSIX-compliant profile.
# This loads the baseline aliases, functions, and other settings.
#
if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi

# ==============================================================================
# Homebrew Shell Environment
#
# Sets up Homebrew environment variables (HOMEBREW_PREFIX, HOMEBREW_CELLAR,
# HOMEBREW_REPOSITORY) and updates PATH, MANPATH, INFOPATH.
# This is the recommended way to initialize Homebrew in login shells.
# ==============================================================================

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    # Apple Silicon (ARM) Macs
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    # Intel Macs
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ==============================================================================
# Local Overrides
#
# Source machine-specific settings that shouldn't be tracked in git.
# Create ~/.zprofile.local for custom PATH additions, proxy settings, etc.
# ==============================================================================

[[ -f "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
