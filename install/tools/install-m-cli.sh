#!/usr/bin/env bash

# ==============================================================================
#
# Tool: m-cli
#
# This script checks for the presence of m-cli and installs it if it is
# missing. m-cli is a suite of command-line tools for managing macOS.
#
# ==============================================================================

#
# The main logic for installing m-cli.
#
main() {
  msg_info "Checking for m-cli..."

  # Check if the m command is already available.
  if command -v "m" >/dev/null 2>&1; then
    msg_success "m-cli is already installed."
    return 0
  fi

  msg_warning "m-cli is not installed."
  msg_info "The installer will now attempt to install m-cli using Homebrew."

  # Install m-cli using the `brew` command.
  if brew install m-cli; then
    msg_success "m-cli installed successfully."
  else
    msg_error "m-cli installation failed."
    msg_error "Please ensure Homebrew is installed correctly and try again."
    return 1
  fi
}

#
# Execute the main function.
#
main
