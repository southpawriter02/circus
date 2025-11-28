#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: UI & UX Configuration
#
# DESCRIPTION:
#   This script configures global settings for the macOS user interface and
#   user experience. These are system-wide preferences that affect all
#   applications and the overall look and feel of macOS.
#
# REQUIRES:
#   - macOS 10.7 (Lion) or later
#
# REFERENCES:
#   - Apple Support: Change System Preferences on Mac
#     https://support.apple.com/guide/mac-help/change-system-preferences-mh15217/mac
#   - Apple Human Interface Guidelines
#     https://developer.apple.com/design/human-interface-guidelines/macos/overview/themes/
#   - defaults command: man defaults
#   - Mathias Bynens' dotfiles (inspiration)
#     https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#
# DOMAIN:
#   NSGlobalDomain         - System-wide preferences
#   com.apple.LaunchServices - App launch and quarantine settings
#
# NOTES:
#   - NSGlobalDomain settings affect all applications
#   - Some settings may require logging out and back in to take effect
#   - Disabling quarantine is a power-user setting with security implications
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
# This version always writes to NSGlobalDomain since these are global settings.
run_defaults() {
  local key="$1"
  local type="$2"
  local value="$3"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set UI/UX preference: '$key' to '$value'"
  else
    # These are global settings, so we use the NSGlobalDomain.
    defaults write NSGlobalDomain "$key" "$type" "$value"
  fi
}

msg_info "Configuring global UI and UX settings..."

# ==============================================================================
# Scrollbar Visibility
# ==============================================================================

# --- Always Show Scrollbars ---
# Key:          AppleShowScrollBars
# Description:  Controls when scrollbars are visible in windows and views.
#               "Always" ensures you can always see your scroll position
#               without needing to interact with the content first.
# Default:      "WhenScrolling" (scrollbars appear only when scrolling)
# Possible:     "WhenScrolling" = Show only when scrolling
#               "Automatic"     = Show based on input device (trackpad vs mouse)
#               "Always"        = Always visible
# Set to:       "Always" (always know where you are in a document)
# Reference:    System Preferences > General > Show scroll bars
run_defaults "AppleShowScrollBars" "-string" "Always"

# ==============================================================================
# Dialog Box Behavior
# ==============================================================================

# --- Expand Save Panel by Default ---
# Key:          NSNavPanelExpandedStateForSaveMode, NSNavPanelExpandedStateForSaveMode2
# Description:  Controls whether the Save dialog box is expanded by default,
#               showing the full file system navigator instead of a condensed
#               view with just the filename field.
# Default:      false (condensed view)
# Possible:     true, false
# Set to:       true (full navigator for easier file management)
# Reference:    File > Save (⌘S) in any application
# Note:         Two keys are used for compatibility across different macOS versions
run_defaults "NSNavPanelExpandedStateForSaveMode" "-bool" "true"
run_defaults "NSNavPanelExpandedStateForSaveMode2" "-bool" "true"

# --- Expand Print Panel by Default ---
# Key:          PMPrintingExpandedStateForPrint, PMPrintingExpandedStateForPrint2
# Description:  Controls whether the Print dialog box is expanded by default,
#               showing all print options instead of a simplified view.
# Default:      false (condensed view)
# Possible:     true, false
# Set to:       true (full options for precise print control)
# Reference:    File > Print (⌘P) in any application
# Note:         Two keys are used for compatibility across different macOS versions
run_defaults "PMPrintingExpandedStateForPrint" "-bool" "true"
run_defaults "PMPrintingExpandedStateForPrint2" "-bool" "true"

# ==============================================================================
# Application Security
# ==============================================================================

# --- Disable Application Quarantine Warning ---
# Key:          LSQuarantine
# Domain:       com.apple.LaunchServices
# Description:  Controls whether macOS shows the "Are you sure you want to
#               open this application?" dialog for applications downloaded
#               from the internet. When enabled (true), the warning is shown.
# Default:      true (quarantine enabled - warning is shown)
# Possible:     true (show warning), false (suppress warning)
# Set to:       false (disable quarantine warning)
#
# ⚠️  SECURITY WARNING:
#     This is a power-user setting that reduces security. Only disable if:
#     1. You carefully verify the source of all downloaded applications
#     2. You use antivirus/anti-malware software
#     3. You understand the risks of running unverified code
#
# Reference:    System Preferences > Security & Privacy > General
# Note:         This does NOT affect Gatekeeper or code signing requirements
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set com.apple.LaunchServices preference: 'LSQuarantine' to 'false'"
else
  defaults write com.apple.LaunchServices LSQuarantine -bool false
fi


msg_success "Global UI and UX settings applied."
