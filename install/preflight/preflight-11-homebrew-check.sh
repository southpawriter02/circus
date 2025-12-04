#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Homebrew
#
# This script checks if Homebrew, the package manager for macOS, is installed.
# Homebrew is a core dependency for this dotfile setup, as it is used to
# install many of the required tools and applications.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking for Homebrew..."

  # Allow command injection for testing
  local brew_cmd="${BREW_CMD:-brew}"

  # The `command -v` command checks if a command is available in the system's
  # PATH. We use it to check for the `brew` command.
  # The output is redirected to /dev/null to keep the output clean.
  if command -v "$brew_cmd" >/dev/null 2>&1; then
    msg_success "Homebrew is installed."
    return 0
  else
    msg_error "Homebrew is not installed."
    msg_info "You can install it by running the following command in your terminal:"
    msg_info "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    return 1
  fi
}

#
# Execute the main function.
#
main
