#!/usr/bin/env bash

# ==============================================================================
#
# Homebrew Step 4: Install All Dependencies from Brewfile
#
# This script uses `brew bundle` to install all dependencies (taps, formulae,
# casks, and fonts) defined in the main Brewfile. This is the primary
# mechanism for installing software. It supports Dry Run mode.
#
# ==============================================================================

#
# The main logic for installing all Homebrew dependencies.
#
main() {
  msg_info "Installing all dependencies from Brewfile..."

  local brewfile_path="$DOTFILES_ROOT/etc/Brewfile"

  if [ ! -f "$brewfile_path" ]; then
    msg_warning "Brewfile not found at '$brewfile_path'. Skipping all Homebrew installations."
    return 0
  fi

  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Checking Brewfile dependencies..."
    # The `check` command will list any missing dependencies without installing them.
    # We add `|| true` because `check` exits with a non-zero status if items
    # are missing, and we don't want `set -e` to halt the dry run.
    brew bundle check --file="$brewfile_path" || true
  else
    msg_info 'Running `brew bundle install`... This may take a while.'
    # The `brew bundle` command is idempotent and will only install missing items.
    if brew bundle install --file="$brewfile_path"; then
      msg_success "Brewfile dependencies installed successfully."
    else
      msg_error "Brewfile installation failed. Please check the output above."
    fi
  fi
}

#
# Execute the main function.
#
main
