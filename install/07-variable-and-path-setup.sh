#!/usr/bin/env bash

# ==============================================================================
#
# Stage 7: Variable and Path Setup
#
# This script configures the shell environment by setting and exporting
# essential variables and paths. This ensures that the dotfiles and other
# tools function correctly.
#
# Its responsibilities include:
#
#   7.1. Setting and exporting core environment variables (e.g., $HOME, $DOTFILES).
#   7.2. Configuring history-related environment variables.
#   7.3. Setting up SSH-related environment variables.
#
# ==============================================================================

#
# The main logic for the variable and path setup stage.
#
main() {
  msg_info "Stage 7: Variable and Path Setup"

  # --- Core Variables ---------------------------------------------------------
  # These variables define the core locations for the dotfiles configuration.
  # The `$DOTFILES_DIR` is inherited from the main `install.sh` script.

  msg_info "Exporting core environment variables..."

  # @description: The directory for Zsh-specific configuration files.
  # @customization: Change this if you prefer a different structure.
  export ZDOTDIR="${ZDOTDIR:-$DOTFILES_DIR/.config/zsh}"

  # @description: The directory for Bash-specific configuration files.
  # @customization: Change this if you prefer a different structure.
  export BASHDIR="${BASHDIR:-$DOTFILES_DIR/.config/bash}"

  # --- Shell History Variables ------------------------------------------------
  # These variables control the behavior of the shell's command history.

  msg_info "Exporting shell history variables..."

  # @description: The path to the Zsh history file.
  export HISTFILE="${HISTFILE:-$ZDOTDIR/.zsh_history}"

  # @description: The number of lines of history to keep in memory.
  export HISTSIZE="${HISTSIZE:-10000}"

  # @description: The number of lines of history to save to the history file.
  export SAVEHIST="${SAVEHIST:-10000}"

  # --- SSH Environment Variables ----------------------------------------------
  # These variables define the location for SSH keys and related configuration.

  msg_info "Exporting SSH environment variables..."

  # @description: The path to the directory containing SSH keys.
  export SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh}"

  msg_success "All environment variables have been set and exported."
}

#
# Execute the main function.
#
main
