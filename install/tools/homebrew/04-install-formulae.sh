#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 4: Install Formulae
#
# This script installs all the command-line tools (formulae) that are
# defined in the Brewfile. It is idempotent, checking if each formula is
# already installed before attempting to install it.
#
# ==============================================================================

#
# The main logic for installing Homebrew formulae.
#
main() {
  msg_info "Installing Homebrew formulae from Brewfile..."

  local brewfile_path="$DOTFILES_DIR/etc/Brewfile"

  if [ ! -f "$brewfile_path" ]; then
    msg_warning "Brewfile not found at '$brewfile_path'. Skipping formulae."
    return 0
  fi

  # Grep for brew lines, remove the 'brew' command and quotes, then process each one.
  grep -E '^\s*brew' "$brewfile_path" | awk -F' ' '{print $2}' | tr -d '"' | while read -r formula_name; do
    # Check if the formula is already installed.
    if brew list "$formula_name" >/dev/null 2>&1; then
      msg_success "Formula '$formula_name' is already installed."
    else
      msg_info "Installing '$formula_name'..."
      if brew install "$formula_name"; then
        msg_success "Successfully installed '$formula_name'."
      else
        msg_error "Failed to install '$formula_name'."
      fi
    fi
  done

  msg_success "Homebrew formula installation complete."
}

#
# Execute the main function.
#
main
