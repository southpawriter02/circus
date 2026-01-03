#!/bin/bash

# ==============================================================================
#
# FILE:         fc-env.sh
#
# DESCRIPTION:  Shared environment setup for Flying Circus Raycast scripts.
#               This file is sourced by all script commands to set up the PATH
#               and DOTFILES_ROOT for the fc command framework.
#
# USAGE:        source "$(dirname "$0")/fc-env.sh"
#
# NOTE:         The __DOTFILES_ROOT__ placeholder is replaced during installation
#               by the `fc raycast install` command.
#
# ==============================================================================

# Set up PATH for Raycast's minimal environment
# Include both Apple Silicon and Intel Homebrew paths
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Set DOTFILES_ROOT (replaced during install)
DOTFILES_ROOT="__DOTFILES_ROOT__"
export DOTFILES_ROOT

# Add dotfiles bin to PATH
export PATH="$DOTFILES_ROOT/bin:$PATH"
