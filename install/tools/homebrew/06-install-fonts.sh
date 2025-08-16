#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 6: Install Fonts
#
# This script installs all the fonts that are defined in the Brewfile. It is
# idempotent, checking if each font is already installed before attempting to
# install it.
#
# ==============================================================================

#
# The main logic for installing Homebrew fonts.
#
main() {
  msg_info "Installing Homebrew fonts from Brewfile..."

  local brewfile_path="$DOTFILES_DIR/etc/Brewfile"

  if [ ! -f "$brewfile_path" ]; then
    msg_warning "Brewfile not found at '$brewfile_path'. Skipping fonts."
    return 0
  fi

  # Grep for cask lines that start with 'font-', remove the 'cask' command and quotes, then process each one.
  grep -E '^\s*cask "font-' "$brewfile_path" | awk -F' ' '{print $2}' | tr -d '"' | while read -r font_name; do
    # Check if the font is already installed.
    if brew list --cask "$font_name" >/dev/null 2>&1; then
      msg_success "Font '$font_name' is already installed."
    else
      msg_info "Installing '$font_name'..."
      if brew install --cask "$font_name"; then
        msg_success "Successfully installed '$font_name'."
      else
        msg_error "Failed to install '$font_name'."
      fi
    fi
  done

  msg_success "Homebrew font installation complete."
}

#
# Execute the main function.
#
main
