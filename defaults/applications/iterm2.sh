#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: iTerm2 Configuration
#
# DESCRIPTION:
#   This script configures iTerm2 to load its preferences from a custom,
#   version-controlled directory within this dotfiles repository. This
#   enables syncing iTerm2 settings across multiple machines.
#
# REQUIRES:
#   - iTerm2 installed (brew install --cask iterm2)
#   - macOS 10.12 (Sierra) or later for full functionality
#
# REFERENCES:
#   - iTerm2 Documentation
#     https://iterm2.com/documentation.html
#   - iTerm2 Preferences: Load preferences from custom folder
#     https://iterm2.com/documentation-preferences-general.html
#   - iTerm2 Shell Integration
#     https://iterm2.com/documentation-shell-integration.html
#
# DOMAIN:
#   com.googlecode.iterm2
#
# SYNC SETUP:
#   1. Open iTerm2 manually first to create default preferences
#   2. Go to Preferences > General > Preferences
#   3. Check "Load preferences from a custom folder or URL"
#   4. Select the folder: $DOTFILES_DIR/etc/iterm2
#   5. Check "Save changes to folder when iTerm2 quits"
#
# NOTES:
#   - iTerm2 must be restarted after changing the preferences folder
#   - Preferences are stored in a .plist file in the sync folder
#   - Color schemes, profiles, and key mappings are all synced
#   - iTerm2 is the most popular terminal emulator for macOS development
#
# ==============================================================================

main() {
  msg_info "Configuring iTerm2 to use settings from this repository..."

  # --- Configuration ---
  # Path to the directory containing iTerm2 preferences to sync.
  # This directory should contain com.googlecode.iterm2.plist or similar.
  local custom_prefs_dir="$DOTFILES_DIR/etc/iterm2"

  # ==============================================================================
  # iTerm2 Preferences Configuration
  # ==============================================================================

  # --- Enable Loading Preferences from Custom Folder ---
  # Key:          LoadPrefsFromCustomFolder
  # Description:  Tells iTerm2 to load its preferences from a custom folder
  #               instead of the default ~/Library/Preferences location.
  #               This enables version control and syncing of preferences.
  # Default:      false (use default location)
  # Possible:     true, false
  # Set to:       true (load from custom folder)
  # Reference:    iTerm2 > Preferences > General > Preferences
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set iTerm2 preference: LoadPrefsFromCustomFolder to true"
  else
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  fi

  # --- Specify Custom Preferences Folder Path ---
  # Key:          PrefsCustomFolder
  # Description:  Specifies the path to the folder containing iTerm2
  #               preferences. iTerm2 will read and write its preferences
  #               file to this location.
  # Default:      (none - uses ~/Library/Preferences)
  # Possible:     Any valid directory path
  # Set to:       $DOTFILES_DIR/etc/iterm2
  # Reference:    iTerm2 > Preferences > General > Preferences
  # Tip:          Commit the preferences file to your dotfiles repo
  #               to sync settings across machines
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set iTerm2 preference: PrefsCustomFolder to $custom_prefs_dir"
  else
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$custom_prefs_dir"
  fi

  msg_success "iTerm2 configuration complete."
  msg_info "You may need to restart iTerm2 for the new settings to take effect."
}

main
