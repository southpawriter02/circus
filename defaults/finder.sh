#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Finder Configuration
#
# This script configures settings for the macOS Finder. It is sourced by
# Stage 11 of the main installer. It supports Dry Run mode.
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Finder preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Finder settings..."

# ------------------------------------------------------------------------------
# Basic Finder View Options
# ------------------------------------------------------------------------------

# --- Show Path Bar ---
# Description: Shows the full file path at the bottom of Finder windows.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.finder" "ShowPathbar" "-bool" "true"

# --- Show Status Bar ---
# Description: Shows the item count and disk space at the bottom of Finder windows.
# Default:      true
# Possible:     true, false
# Set to:       true (no change from default, but explicit is good)
run_defaults "com.apple.finder" "ShowStatusBar" "-bool" "true"

# --- Show All File Extensions ---
# Description: Controls whether Finder displays all file extensions (e.g., .txt, .jpg).
# Default:      false
# Possible:     true, false
# Set to:       true (essential for developers)
# Note: This is a global preference, not specific to com.apple.finder.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set global preference: AppleShowAllExtensions to true"
else
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi

# --- Default View Style ---
# Description: Sets the default view style for new Finder windows.
# Default:      'icnv' (Icon View)
# Possible:     'icnv' (Icon), 'clmv' (Column), 'Nlsv' (List), 'glyv' (Gallery)
# Set to:       'clmv' (Column View is often preferred by developers for navigation)
run_defaults "com.apple.finder" "FXPreferredViewStyle" "-string" "clmv"

# ------------------------------------------------------------------------------
# Advanced Finder Behavior
# ------------------------------------------------------------------------------

# --- Show Hidden Files ---
# Description: Controls whether Finder shows hidden files (those starting with a dot).
# Default:      false
# Possible:     true, false
# Set to:       true (essential for developers to see files like .gitignore)
run_defaults "com.apple.finder" "AppleShowAllFiles" "-bool" "true"

# --- Search Scope ---
# Description: Determines the default search scope in Finder.
# Default:      'SCev' (Search This Mac)
# Possible:     'SCev' (This Mac), 'SCcf' (Current Folder), 'SCsp' (Previous Scope)
# Set to:       'SCcf' (Searching the current folder is usually more intuitive)
run_defaults "com.apple.finder" "FXDefaultSearchScope" "-string" "SCcf"

# --- Keep Folders on Top ---
# Description: When sorting by name, this keeps folders grouped together at the top.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.finder" "_FXSortFoldersFirst" "-bool" "true"

# --- Disable Warning on Extension Change ---
# Description: Disables the warning dialog when changing a file's extension.
# Default:      false (warning is shown)
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.finder" "FXEnableExtensionChangeWarning" "-bool" "false"

# ------------------------------------------------------------------------------
# Apply Changes
# ------------------------------------------------------------------------------

# Changes to Finder require restarting the Finder process to take effect.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart Finder to apply changes."
else
  msg_info "Restarting Finder to apply changes..."
  killall Finder
fi

msg_success "Finder settings applied."
