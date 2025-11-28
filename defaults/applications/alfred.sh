#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Alfred Configuration
#
# DESCRIPTION:
#   This script configures Alfred to sync its settings from a custom,
#   version-controlled directory within this dotfiles repository. Alfred
#   is a powerful launcher and productivity application for macOS.
#
# REQUIRES:
#   - Alfred installed (brew install --cask alfred)
#   - Alfred Powerpack for sync feature (optional but recommended)
#   - Alfred must have been run at least once to create preferences
#
# REFERENCES:
#   - Alfred Knowledge Base
#     https://www.alfredapp.com/help/
#   - Alfred Sync Documentation
#     https://www.alfredapp.com/help/advanced/sync/
#   - Alfred Workflow Development
#     https://www.alfredapp.com/help/workflows/
#
# DOMAIN:
#   com.runningwithcrayons.Alfred-Preferences
#
# SYNC SETUP:
#   1. Open Alfred Preferences (⌘,)
#   2. Go to Advanced tab
#   3. Click "Set preferences folder..."
#   4. Select the folder: $DOTFILES_DIR/etc/alfred
#   5. Alfred will copy current preferences to this folder
#
# WHAT GETS SYNCED:
#   - Appearance settings (themes)
#   - Features configuration
#   - Workflows (Powerpack required)
#   - Clipboard history settings
#   - Snippets (Powerpack required)
#   - File search settings
#
# NOTES:
#   - Alfred must be restarted for sync folder changes to take effect
#   - Workflows with sensitive data should be excluded from version control
#   - Alfred Powerpack is a paid upgrade that enables workflows and sync
#
# ==============================================================================

main() {
  msg_info "Configuring Alfred to use settings from this repository..."

  # --- Prerequisite Check ---
  # We need to find the Alfred preferences file, which requires Alfred
  # to have been run at least once.
  local alfred_prefs_domain="com.runningwithcrayons.Alfred-Preferences"
  if ! defaults domains | grep -q "$alfred_prefs_domain"; then
    msg_warning "Alfred preferences not found. Is Alfred installed and has it been run at least once?"
    return 1
  fi

  # --- Configuration ---
  # Path to the directory containing Alfred preferences to sync.
  # This directory should contain Alfred's preference files and workflows.
  local sync_folder="$DOTFILES_DIR/etc/alfred"

  # ==============================================================================
  # Alfred Preferences Configuration
  # ==============================================================================

  # --- Set Sync Folder Path ---
  # Key:          syncfolder
  # Description:  Specifies the path to the folder where Alfred should
  #               store and read its preferences. This enables syncing
  #               Alfred settings across multiple machines.
  # Default:      (none - uses ~/Library/Application Support/Alfred)
  # Possible:     Any valid directory path
  # Set to:       $DOTFILES_DIR/etc/alfred
  # Reference:    Alfred Preferences > Advanced > Set preferences folder
  # Note:         Alfred will create necessary files in this folder
  #               if they don't exist
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Alfred preference: syncfolder to $sync_folder"
  else
    defaults write "$alfred_prefs_domain" "syncfolder" -string "$sync_folder"
  fi

  msg_success "Alfred configuration complete."
  msg_info "You may need to restart Alfred for the new settings to take effect."
}

main
