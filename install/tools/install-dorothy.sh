#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Dorothy
#
# This script installs Dorothy, a utility for finding orphaned dotfiles.
# It supports Dry Run mode.
#
# ==============================================================================

#
# The main logic for installing Dorothy.
#
main() {
  # Check if the dorothy command is already available. If so, do nothing.
  if command -v "dorothy" >/dev/null 2>&1; then
    msg_success "Dorothy is already installed. Skipping."
    return 0
  fi

  msg_info "Installing Dorothy..."

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would install Dorothy using RubyGems."
    return 0
  fi

  msg_info "The installer will now attempt to install Dorothy using RubyGems."

  # Install Dorothy using the `gem` command.
  if gem install dorothy; then
    msg_success "Dorothy installed successfully."
  else
    msg_error "Dorothy installation failed."
    msg_error "Please ensure Ruby and RubyGems are installed and try again."
    return 1
  fi
}

#
# Execute the main function.
#
main
