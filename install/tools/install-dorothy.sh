#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Dorothy
#
# This script checks for the presence of Dorothy and installs it if it is
# missing. Dorothy is a utility for finding orphaned dotfiles.
#
# ==============================================================================

#
# The main logic for installing Dorothy.
#
main() {
  msg_info "Checking for Dorothy..."

  # Check if the dorothy command is already available.
  if command -v "dorothy" >/dev/null 2>&1; then
    msg_success "Dorothy is already installed."
    return 0
  fi

  msg_warning "Dorothy is not installed."
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
