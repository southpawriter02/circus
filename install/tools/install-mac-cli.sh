#!/usr/bin/env bash

# ==============================================================================
#
# Tool: mac-cli
#
# This script installs mac-cli, a command-line tool for managing your Mac.
# It supports Dry Run mode.
#
# ==============================================================================

#
# The main logic for installing mac-cli.
#
main() {
  # Check if the mac command is already available. If so, do nothing.
  if command -v "mac" >/dev/null 2>&1; then
    msg_success "mac-cli is already installed. Skipping."
    return 0
  fi

  msg_info "Installing mac-cli..."

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would install mac-cli using pip."
    return 0
  fi

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
