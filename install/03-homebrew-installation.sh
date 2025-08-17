#!/usr/bin/env bash

# ==============================================================================
#
# Stage 3: Homebrew Installation & Bundle
#
# This script installs Homebrew if it's not already present, and then uses
# the Brewfile in the repository to install all specified packages.
#
# ==============================================================================

main() {
  msg_info "Stage 3: Homebrew Installation & Bundle"

  # --- Homebrew Installation Check ---
  if command -v brew >/dev/null 2>&1; then
    msg_info "Homebrew is already installed. Updating..."
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would run: brew update"
    else
      brew update
    fi
  else
    msg_info "Homebrew not found. Installing..."
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would run the official Homebrew installation script."
    else
      # Run the official Homebrew installation script.
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      # Add Homebrew to the PATH for the current script's execution.
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  fi

  # --- Homebrew Bundle Installation ---
  local brewfile_path="$DOTFILES_DIR/Brewfile"
  if [ -f "$brewfile_path" ]; then
    msg_info "Installing packages from Brewfile..."
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would run: brew bundle install --file=$brewfile_path"
    else
      if brew bundle install --file="$brewfile_path"; then
        msg_success "All packages from Brewfile installed successfully."
      else
        msg_error "An error occurred during `brew bundle install`."
      fi
    fi
  else
    msg_warning "Brewfile not found at $brewfile_path. Skipping bundle installation."
  fi

  msg_success "Homebrew installation stage complete."
}

main
