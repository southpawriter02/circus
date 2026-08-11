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

# --- Re-entrancy Guard --------------------------------------------------------

# Sourcing this file twice in one shell re-runs the `readonly` declarations in
# the libraries below, which fails under the `set -e` that helpers.sh enables and
# kills the process.
#
# This originally guarded `bin/fc`, which sourced the chosen plugin into its own
# shell after having already sourced this file — so every plugin's own
# `source ../init.sh` was a second pass. bin/fc now `exec`s the plugin instead,
# giving it a fresh process where this variable is unset (it is deliberately not
# exported), so that path no longer relies on the guard.
#
# It is still load-bearing for the bats helpers: setup_installer_test sources
# this file once per test case within a single shell.
if [ -n "${_CIRCUS_INIT_DONE:-}" ]; then
  return 0
fi
_CIRCUS_INIT_DONE=1

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

# 4. Source platform detection and OS-specific implementations.
#    This enables cross-platform support for macOS and Linux.
source "$DOTFILES_ROOT/lib/os/detect.sh"

if is_macos; then
    source "$DOTFILES_ROOT/lib/os/macos.sh"
elif is_linux; then
    source "$DOTFILES_ROOT/lib/os/linux.sh"
fi

# 5. Source notification helpers for long-running tasks.
source "$DOTFILES_ROOT/lib/notify.sh"

# 6. Source security library for input sanitization.
source "$DOTFILES_ROOT/lib/security.sh"
