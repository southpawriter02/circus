#!/usr/bin/env bash

# ==============================================================================
#
# Repository Management Step 1: Check for Uncommitted Changes
#
# This script checks if there are any uncommitted changes in the local
# repository. It is good practice to start with a clean state before
# pulling remote changes or performing other Git operations.
#
# ==============================================================================

#
# The main logic for checking for uncommitted changes.
#
main() {
  msg_info "Checking for uncommitted local changes..."

  # The `git status --porcelain` command provides an easy-to-parse summary of
  # the repository's state. If it produces any output, it means there are
  # uncommitted changes.
  if [[ -n "$(git status --porcelain)" ]]; then
    msg_warning "You have uncommitted local changes."
    msg_warning "It is recommended to commit or stash your changes before proceeding."
    # We ask the user if they want to continue despite the warning.
    if ! ask "Do you want to continue anyway?" N; then
      msg_error "Installation aborted by user."
      exit 1
    fi
  else
    msg_success "Repository is clean. No uncommitted changes found."
  fi
}

#
# Execute the main function.
#
main
