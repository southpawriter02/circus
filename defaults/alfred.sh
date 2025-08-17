#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Alfred Configuration
#
# This script configures Alfred to sync its settings from a custom,
# version-controlled directory within this repository.
#
# ==============================================================================

main() {
  msg_info "Configuring Alfred to use settings from this repository..."

  # --- Prerequisite Check ---
  # We need to find the Alfred preferences file, which can be in a few places.
  local alfred_prefs_domain="com.runningwithcrayons.Alfred-Preferences"
  if ! defaults domains | grep -q "$alfred_prefs_domain"; then
    msg_warning "Alfred preferences not found. Is Alfred installed and has it been run at least once?"
    return 1
  fi

  # --- Configuration ---
  local sync_folder="$DOTFILES_DIR/etc/alfred"

  # --- Set Alfred Preferences ---
  # We use the `defaults` command to write directly to Alfred's preferences file.

  # Set the sync folder path.
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Alfred preference: syncfolder to $sync_folder"
  else
    defaults write "$alfred_prefs_domain" "syncfolder" -string "$sync_folder"
  fi

  msg_success "Alfred configuration complete."
  msg_info "You may need to restart Alfred for the new settings to take effect."
}

main
