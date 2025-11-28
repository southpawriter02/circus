#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Finder Configuration
#
# DESCRIPTION:
#   This script configures settings for the macOS Finder, the primary file
#   management application. These settings optimize Finder for developer
#   workflows by showing hidden files, full paths, and file extensions.
#
# REQUIRES:
#   - macOS 10.5 (Leopard) or later
#
# REFERENCES:
#   - Finder Preferences Reference
#     https://support.apple.com/guide/mac-help/finder-mchlp2605/mac
#   - Apple Support: View and sort files in the Finder on Mac
#     https://support.apple.com/guide/mac-help/view-and-sort-files-mchlp1083/mac
#   - Mathias Bynens' dotfiles (inspiration)
#     https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#   - defaults command: man defaults
#
# DOMAINS:
#   com.apple.finder     - Finder-specific settings
#   NSGlobalDomain       - System-wide settings (file extensions)
#
# NOTES:
#   - Changes require restarting Finder to take effect
#   - Some settings are user-specific, others are system-wide
#   - The Finder automatically creates ~/Desktop, ~/Documents, ~/Downloads
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

# ==============================================================================
# Finder Window Display Options
# ==============================================================================

# --- Show Path Bar ---
# Key:          ShowPathbar
# Description:  Shows the full file path at the bottom of Finder windows.
#               Clicking on path components allows quick navigation to
#               parent directories.
# Default:      false (hidden)
# Possible:     true, false
# Set to:       true
# Reference:    View > Show Path Bar (⌥⌘P)
run_defaults "com.apple.finder" "ShowPathbar" "-bool" "true"

# --- Show Status Bar ---
# Key:          ShowStatusBar
# Description:  Shows the item count and available disk space at the bottom
#               of Finder windows. Useful for monitoring storage usage.
# Default:      true
# Possible:     true, false
# Set to:       true (explicit confirmation of default)
# Reference:    View > Show Status Bar (⌘/)
run_defaults "com.apple.finder" "ShowStatusBar" "-bool" "true"

# --- Show All File Extensions ---
# Key:          AppleShowAllExtensions
# Domain:       NSGlobalDomain (system-wide setting)
# Description:  Controls whether Finder displays all file extensions
#               (e.g., .txt, .jpg, .sh). Essential for developers to
#               distinguish between files with similar names.
# Default:      false (extensions hidden for known file types)
# Possible:     true, false
# Set to:       true (essential for developers)
# Reference:    Finder > Preferences > Advanced > Show all filename extensions
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set global preference: AppleShowAllExtensions to true"
else
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi

# --- Default View Style ---
# Key:          FXPreferredViewStyle
# Description:  Sets the default view style for new Finder windows.
#               Column view is preferred by many developers for navigating
#               deep directory structures.
# Default:      'icnv' (Icon View)
# Possible:     'icnv' = Icon View (grid of large icons)
#               'clmv' = Column View (hierarchical columns)
#               'Nlsv' = List View (detailed file list)
#               'glyv' = Gallery View (preview-focused)
# Set to:       'clmv' (Column View for easy navigation)
# Reference:    View > as Columns (⌘3)
run_defaults "com.apple.finder" "FXPreferredViewStyle" "-string" "clmv"

# ==============================================================================
# Advanced Finder Behavior
# ==============================================================================

# --- Show Hidden Files ---
# Key:          AppleShowAllFiles
# Description:  Controls whether Finder shows hidden files (those starting
#               with a dot, like .gitignore, .bashrc, .env).
# Default:      false (hidden files are hidden)
# Possible:     true, false
# Set to:       true (essential for developers working with dotfiles)
# Reference:    Toggle with ⌘⇧. or via this setting
# Note:         This can be temporarily toggled with the keyboard shortcut
#               Command+Shift+Period (⌘⇧.)
run_defaults "com.apple.finder" "AppleShowAllFiles" "-bool" "true"

# --- Default Search Scope ---
# Key:          FXDefaultSearchScope
# Description:  Determines the default search scope when using Finder's
#               search field. Searching the current folder is usually more
#               intuitive than searching the entire Mac.
# Default:      'SCev' (Search This Mac)
# Possible:     'SCev' = Search This Mac (entire computer)
#               'SCcf' = Search the Current Folder only
#               'SCsp' = Use the Previous Search Scope
# Set to:       'SCcf' (Current Folder for focused searching)
# Reference:    Finder > Preferences > Advanced > When performing a search
run_defaults "com.apple.finder" "FXDefaultSearchScope" "-string" "SCcf"

# --- Keep Folders on Top ---
# Key:          _FXSortFoldersFirst
# Description:  When sorting by name, keeps folders grouped together at
#               the top of the list, separate from files. This makes it
#               easier to navigate directory structures.
# Default:      false (folders mixed with files)
# Possible:     true, false
# Set to:       true
# Reference:    Finder > Preferences > Advanced > Keep folders on top
run_defaults "com.apple.finder" "_FXSortFoldersFirst" "-bool" "true"

# --- Disable Extension Change Warning ---
# Key:          FXEnableExtensionChangeWarning
# Description:  Controls whether Finder shows a warning dialog when
#               changing a file's extension. Disabling this removes an
#               unnecessary interruption for power users.
# Default:      true (warning is shown)
# Possible:     true (show warning), false (suppress warning)
# Set to:       false (suppress warning for power users)
# Reference:    This warning appears when renaming a file with a new extension
run_defaults "com.apple.finder" "FXEnableExtensionChangeWarning" "-bool" "false"

# ==============================================================================
# Apply Changes
# ==============================================================================

# Changes to Finder require restarting the Finder process to take effect.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart Finder to apply changes."
else
  msg_info "Restarting Finder to apply changes..."
  killall Finder
fi

msg_success "Finder settings applied."
