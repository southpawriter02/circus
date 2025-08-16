#!/usr/bin/env zsh
# ------------------------------------------------------------------------------
# It is best practice to use `#!/usr/bin/env zsh` instead of a hardcoded
# path like `#!/bin/zsh`. This makes the script more portable, as it
# allows the system's `env` command to find the `zsh` interpreter in the
# user's PATH.
# ------------------------------------------------------------------------------

# ╔════════════════════════════════════════════════════════════════════════════╗
# ║ FILE:        profiles/.zshrc                                               ║
# ║ PROJECT:     Dotfiles Flying Circus                                        ║
# ║ REPOSITORY:  https://github.com/southpawriter02/dotfiles                   ║
# ║ AUTHOR:      southpawriter02 <southpawriter@pm.me>                         ║
# ║                                                                            ║
# ║ DESCRIPTION: This is the main configuration file for Zsh. It is responsible║
# ║              for setting up the shell environment by sourcing other files, ║
# ║              setting the PATH, and loading modular topic configurations.   ║
# ║                                                                            ║
# ║ LICENSE:     MIT                                                           ║
# ║ COPYRIGHT:   Copyright (c) $(date +'%Y') southpawriter02                   ║
# ║ STATUS:      DRAFT                                                         ║
# ╚════════════════════════════════════════════════════════════════════════════╝

# ------------------------------------------------------------------------------
# SECTION: DOTFILES ENVIRONMENT
#
# Description: Sets up the core environment for the dotfiles repository.
# ------------------------------------------------------------------------------

# Set DOTFILES_DIR to the absolute path of the repository's root directory.
# This is done dynamically by finding the location of this .zshrc file,
# which allows the repository to be cloned anywhere on the system.
if [[ -z "${ZSH_VERSION}" ]]; then
  echo "ERROR: This script is designed to be sourced by Zsh." >&2
  return 1
fi
export DOTFILES_DIR="$(cd "$(dirname "${(%):-%x}")/.." && pwd)"


# Add the 'bin' directory to the PATH for custom scripts and commands.
# This ensures that scripts in 'bin/' are executable from anywhere.
export PATH="$DOTFILES_DIR/bin:$PATH"

# ------------------------------------------------------------------------------
# SECTION: LOAD LIBRARIES
#
# Description: Source shared libraries and helper functions.
# ------------------------------------------------------------------------------

# Source the helper library for colored messages and other utilities.
if [[ -f "$DOTFILES_DIR/lib/helpers.sh" ]]; then
  # shellcheck source=/dev/null
  source "$DOTFILES_DIR/lib/helpers.sh"
else
  echo "WARNING: Dotfiles helper library not found at $DOTFILES_DIR/lib/helpers.sh"
fi

# ------------------------------------------------------------------------------
# SECTION: LOAD TOPIC CONFIGURATIONS
#
# Description: Loads all .sh files from the topics/ directory. This allows for
# a modular and organized approach to shell configuration.
# ------------------------------------------------------------------------------

# Check if the topics directory exists.
if [[ -d "$DOTFILES_DIR/topics" ]]; then
  # Loop through all .sh files in the topics directory and source them.
  for topic_file in "$DOTFILES_DIR"/topics/*.sh; do
    if [[ -f "$topic_file" ]]; then
      # shellcheck source=/dev/null
      source "$topic_file"
    fi
  done
  # Unset the variable to keep the shell environment clean.
  unset topic_file
fi

# ------------------------------------------------------------------------------
# SECTION: SHELL OPTIONS & SETTINGS
#
# Description: Configure Zsh-specific options for the interactive shell.
# ------------------------------------------------------------------------------

# TODO: Add Zsh-specific settings here (e.g., history, completion, etc.)


# ------------------------------------------------------------------------------
# SECTION: WELCOME MESSAGE
#
# Description: Displays a welcome message when a new shell is opened.
# ------------------------------------------------------------------------------

# Check if the 'msg_info' function exists before calling it.
if command -v msg_info &> /dev/null; then
  msg_info "Welcome to the Dotfiles Flying Circus! Your shell is ready."
else
  echo "Welcome to the Dotfiles Flying Circus!"
fi
