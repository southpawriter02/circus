#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 3: Add Taps
#
# This script adds any third-party Homebrew taps (repositories) that are
# defined in the Brewfile. This is a necessary step before installing any
# formulae or casks from those taps.
#
# ==============================================================================

#
# The main logic for adding Homebrew taps.
#
main() {
  msg_info "Adding Homebrew taps from Brewfile..."

  local brewfile_path="$DOTFILES_DIR/etc/Brewfile"

  if [ ! -f "$brewfile_path" ]; then
    msg_warning "Brewfile not found at '$brewfile_path'. Skipping taps."
    return 0
  fi

  # Grep for tap lines, remove the 'tap' command and quotes, then process each one.
  grep -E '^\s*tap' "$brewfile_path" | awk -F' ' '{print $2}' | tr -d '"' | while read -r tap_name; do
    # Check if the tap is already installed.
    if brew tap | grep -q "^${tap_name}$"; then
      msg_success "Tap '$tap_name' is already installed."
    else
      msg_info "Tapping '$tap_name'..."
      if brew tap "$tap_name"; then
        msg_success "Successfully tapped '$tap_name'."
      else
        msg_error "Failed to tap '$tap_name'."
      fi
    fi
  done

  msg_success "Homebrew tap setup complete."
}

#
# Execute the main function.
#
main
