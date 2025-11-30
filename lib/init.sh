#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/init.sh
#
# DESCRIPTION:  This is the centralized initialization script for the entire
#               project. It is responsible for setting up the shell environment,
#               defining global constants, and sourcing all helper libraries.
#
#               Every executable script in this project should source this
#               file as its very first action.
#
# ==============================================================================

# --- Define Global Constants ------------------------------------------------

# The absolute path to the root of the dotfiles repository.
# This provides a reliable anchor point for all other scripts.
export DOTFILES_ROOT
DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# The root directory for the installer scripts.
export INSTALL_DIR="$DOTFILES_ROOT/install"

# --- Source Helper Libraries ------------------------------------------------

# The order of sourcing is important.

# 1. Source the logging and error-handling library first, as it sets up
#    the foundational `set -e` and `trap` commands.
source "$DOTFILES_ROOT/lib/helpers.sh"

# 2. Source the enhanced UI library for terminal interface components.
source "$DOTFILES_ROOT/lib/ui.sh"

# 3. Source the configuration library, which provides role-specific settings.
source "$DOTFILES_ROOT/lib/config.sh"
