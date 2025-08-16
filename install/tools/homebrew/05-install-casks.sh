#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 5: Install Casks
#
# This script installs all the GUI applications (casks) that are defined in
# the Brewfile. It is idempotent, checking if each cask is already installed
# before attempting to install it.
#
# ==============================================================================

#
# The main logic for installing Homebrew casks.
#
main() {
  msg_info "Installing Homebrew casks from Brewfile..."

  local brewfile_path="$DOTFILES_DIR/etc/Brewfile"

  if [ ! -f "$brewfile_path" ]; then
    msg_warning "Brewfile not found at '$brewfile_path'. Skipping casks."
    return 0
  fi

  # Grep for cask lines, remove the 'cask' command and quotes, then process each one.
  grep -E '^\s*cask' "$brewfile_path" | awk -F' ' '{print $2}' | tr -d '"' | while read -r cask_name; do
    # Check if the cask is already installed.
    if brew list --cask "$cask_name" >/dev/null 2>&1; then
      msg_success "Cask '$cask_name' is already installed."
    else
      msg_info "Installing '$cask_name'..."
      if brew install --cask "$cask_name"; then
        msg_success "Successfully installed '$cask_name'."
      else
        msg_error "Failed to install '$cask_name'."
      fi
    fi
  done

  msg_success "Homebrew cask installation complete."
}

#
# Execute the main function.
#
main
