#!/usr/bin/env bash

# ==============================================================================
#
# Tool: mac-cli
#
# This script checks for the presence of mac-cli and installs it if it is
# missing. mac-cli is a command-line tool for managing your Mac.
#
# ==============================================================================

#
# The main logic for installing mac-cli.
#
main() {
  msg_info "Checking for mac-cli..."

  # Check if the mac command is already available.
  if command -v "mac" >/dev/null 2>&1; then
    msg_success "mac-cli is already installed."
    return 0
  fi

  msg_warning "mac-cli is not installed."
  msg_info "The installer will now attempt to install mac-cli using pip."

  # Install mac-cli using the `pip` command.
  if pip install mac-cli; then
    msg_success "mac-cli installed successfully."
  else
    msg_error "mac-cli installation failed."
    msg_error "Please ensure Python and pip are installed and try again."
    return 1
  fi
}

#
# Execute the main function.
#
main
