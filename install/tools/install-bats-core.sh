#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Bats (Bash Automated Testing System)
#
# This script checks for the presence of bats-core and installs it if it is
# missing. Bats is the testing framework used for this project.
#
# ==============================================================================

#
# The main logic for installing bats-core.
#
main() {
  msg_info "Checking for bats-core..."

  # Check if the bats command is already available.
  if command -v "bats" >/dev/null 2>&1; then
    msg_success "bats-core is already installed."
    return 0
  fi

  msg_warning "bats-core is not installed."
  msg_info "The installer will now attempt to install bats-core using Homebrew."

  # Install bats-core using the `brew` command.
  if brew install bats-core; then
    msg_success "bats-core installed successfully."
  else
    msg_error "bats-core installation failed."
    msg_error "Please ensure Homebrew is installed correctly and try again."
    return 1
  fi
}

#
# Execute the main function.
#
main
