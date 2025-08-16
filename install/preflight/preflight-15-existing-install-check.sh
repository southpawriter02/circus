#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Existing Installation
#
# This script checks for the presence of an install marker. Install markers are
# empty files that are created after a successful installation. They can be
# used to determine if the installation has been run before.
#
# This can be useful for preventing the installation from running again
# unnecessarily.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # You can change the path of the install marker file by modifying the
  # INSTALL_MARKER_PATH variable.
  #
  local INSTALL_MARKER_PATH="$HOME/.dotfiles-installed"

  msg_info "Checking for existing installation..."

  # Check if the install marker file exists.
  if [ -f "$INSTALL_MARKER_PATH" ]; then
    msg_warning "An existing installation was found. If you continue, the installation will run again."
  else
    msg_success "No previous installation was found."
  fi

  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
