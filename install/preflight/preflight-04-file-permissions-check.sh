#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: File Permissions
#
# This script checks if the user has the necessary file permissions to create
# and modify files in their home directory. The installation process needs to
# be able to write to various locations in the home directory, so this check
# is crucial for preventing permission-related errors.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking file permissions..."

  # We test for write permissions by attempting to create a temporary file in the
  # user's home directory. The file is removed immediately after the check.
  local TEST_FILE="$HOME/.dotfiles-permission-test"

  # The `touch` command attempts to create the file. We redirect any error
  # messages to /dev/null to keep the output clean.
  if touch "$TEST_FILE" 2>/dev/null; then
    # If the file was created successfully, remove it and report success.
    rm "$TEST_FILE"
    msg_success "User has write permissions in the home directory."
    return 0
  else
    # If the file could not be created, report an error and exit.
    msg_error "User does not have write permissions in the home directory."
    return 1
  fi
}

#
# Execute the main function.
#
main
