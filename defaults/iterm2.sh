#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: iTerm2 Configuration
#
# This script configures iTerm2 to load its preferences from a custom,
# version-controlled directory within this repository.
#
# ==============================================================================

main() {
  msg_info "Configuring iTerm2 to use settings from this repository..."

  # --- Configuration ---
  local custom_prefs_dir="$DOTFILES_DIR/etc/iterm2"

  # --- Set iTerm2 Preferences ---
  # We use the `defaults` command to write directly to iTerm2's preferences file.

  # Tell iTerm2 to load preferences from a custom folder.
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set iTerm2 preference: LoadPrefsFromCustomFolder to true"
  else
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  fi

  # Specify the path to the custom folder.
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set iTerm2 preference: PrefsCustomFolder to $custom_prefs_dir"
  else
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$custom_prefs_dir"
  fi

  msg_success "iTerm2 configuration complete."
  msg_info "You may need to restart iTerm2 for the new settings to take effect."
}

main
