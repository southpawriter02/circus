#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Admin Rights
#
# This script checks if the current user has administrator privileges. Some
# dotfile installations may require admin rights to install certain software
# or to modify system-level settings.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking for admin rights..."

  # Allow command injection for testing
  local groups_cmd="${GROUPS_CMD:-groups}"

  # On macOS, users with administrator privileges are members of the "admin" group.
  # The `groups` command lists the groups the current user is a member of.
  # We use `grep -q` to quietly search for the "admin" group in the output.
  if $groups_cmd | grep -q "\badmin\b"; then
    msg_success "User has admin rights."
  else
    msg_warning "User does not have admin rights. Some parts of the installation may fail."
  fi
  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
