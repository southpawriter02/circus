#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: macOS
#
# This script checks if the operating system is macOS. Many of the dotfile
# configurations and installation scripts are specific to macOS, so it is
# important to ensure that the script is running on a supported platform.
#
# This is the first and most fundamental check.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking for macOS..."

  # Allow command injection for testing
  local uname_cmd="${UNAME_CMD:-uname}"

  # The `uname` command returns the name of the operating system kernel.
  # On macOS, this command returns "Darwin".
  if [[ "$($uname_cmd)" == "Darwin" ]]; then
    msg_success "Operating system is macOS."
    # Exit with a status of 0 to indicate success.
    return 0
  else
    msg_error "This installation is only supported on macOS."
    # Exit with a status of 1 to indicate failure.
    return 1
  fi
}

#
# Execute the main function.
#
main
