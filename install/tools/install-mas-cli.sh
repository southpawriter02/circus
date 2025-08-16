#!/usr/bin/env bash

# ==============================================================================
#
# Tool: mas-cli
#
# This script checks for the presence of mas-cli and installs it if it is
# missing. mas-cli is a command-line interface for the Mac App Store.
#
# ==============================================================================

#
# The main logic for installing mas-cli.
#
main() {
  msg_info "Checking for mas-cli..."

  # Check if the mas command is already available.
  if command -v "mas" >/dev/null 2>&1; then
    msg_success "mas-cli is already installed."
    return 0
  fi

  msg_warning "mas-cli is not installed."
  msg_info "The installer will now attempt to install mas-cli using Homebrew."

  # Install mas-cli using the `brew` command.
  if brew install mas; then
    msg_success "mas-cli installed successfully."
  else
    msg_error "mas-cli installation failed."
    msg_error "Please ensure Homebrew is installed correctly and try again."
    return 1
  fi
}

#
# Execute the main function.
#
main
