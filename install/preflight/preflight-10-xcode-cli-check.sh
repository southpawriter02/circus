#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Xcode Command Line Tools
#
# This script checks if the Xcode Command Line Tools are installed. These tools
# are a prerequisite for many development-related tasks on macOS, such as
# compiling software from source and using Git.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking for Xcode Command Line Tools..."

  # Allow command injection for testing
  local xcode_select_cmd="${XCODE_SELECT_CMD:-xcode-select}"

  # The `xcode-select -p` command prints the path to the active developer
  # directory. If this command returns a non-zero exit code, it means the
  # tools are not installed.
  # We redirect the output to /dev/null to keep the output clean.
  if $xcode_select_cmd -p >/dev/null 2>&1; then
    msg_success "Xcode Command Line Tools are installed."
    return 0
  else
    msg_error "Xcode Command Line Tools are not installed."
    msg_info "You can install them by running the following command in your terminal:"
    msg_info "xcode-select --install"
    return 1
  fi
}

#
# Execute the main function.
#
main
