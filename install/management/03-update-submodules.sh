#!/usr/bin/env bash

# ==============================================================================
#
# Repository Management Step 3: Update Submodules
#
# This script checks for and updates any Git submodules that are part of
# the repository. This ensures that all required dependencies are present.
#
# ==============================================================================

#
# The main logic for updating submodules.
#
main() {
  # First, check if a .gitmodules file exists in the root of the repository.
  # If it doesn't, there are no submodules to manage.
  if [ ! -f "$DOTFILES_DIR/.gitmodules" ]; then
    msg_info "No submodules found to initialize."
    return 0
  fi

  msg_info "Initializing and updating submodules..."

  # The `git submodule update` command handles both initialization and updates.
  # --init: Initializes any submodules that have not yet been cloned.
  # --recursive: Handles nested submodules (submodules within submodules).
  if git submodule update --init --recursive; then
    msg_success "Submodules initialized and updated successfully."
  else
    msg_error "Failed to initialize or update submodules."
    # This is not a fatal error, so we warn the user but don't exit.
    msg_warning "You may need to run 'git submodule update --init' manually."
  fi
}

#
# Execute the main function.
#
main
