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
# Domain:       NSGlobalDomain
# Description:  Controls when scrollbars are visible in windows and views.
#               "Always" ensures you can always see your scroll position
#               without needing to interact with the content first. This
#               is especially useful when working with long documents or
#               when using a mouse instead of a trackpad.
# Default:      Automatic (behavior depends on input device)
# Options:      WhenScrolling = Show only when actively scrolling
#               Automatic     = Show based on input device (trackpad vs mouse)
#               Always        = Always visible in scrollable areas
# Set to:       Always (constant awareness of document position)
# UI Location:  System Settings > Appearance > Show scroll bars
# Source:       https://support.apple.com/guide/mac-help/change-appearance-settings-mchlp1225/mac
# Note:         With trackpads, Apple defaults to hiding scrollbars since
#               two-finger scrolling is intuitive. "Always" is better for
#               mouse users or those who prefer visual scroll indicators.
run_defaults "AppleShowScrollBars" "-string" "Always"

# ==============================================================================
# Dialog Box Behavior
# ==============================================================================

# --- Expand Save Panel by Default ---
# Key:          NSNavPanelExpandedStateForSaveMode
#               NSNavPanelExpandedStateForSaveMode2
# Domain:       NSGlobalDomain
# Description:  Controls whether the Save dialog box is expanded by default,
#               showing the full file system navigator instead of a condensed
#               view with just the filename field. The expanded view allows
#               you to navigate folders, create new folders, and see the
#               complete save location.
# Default:      false (condensed view with minimal options)
# Options:      true  = Show expanded view with full file browser
#               false = Show condensed view with just filename
# Set to:       true (full navigator for easier file management)
# UI Location:  File > Save (⌘S) dialog - click disclosure arrow to expand
# Source:       https://support.apple.com/guide/mac-help/save-documents-mchlp1088/mac
# Note:         Two keys are used for compatibility across different macOS
#               versions. Both should be set to ensure the setting works.
run_defaults "NSNavPanelExpandedStateForSaveMode" "-bool" "true"
run_defaults "NSNavPanelExpandedStateForSaveMode2" "-bool" "true"

# --- Expand Print Panel by Default ---
# Key:          PMPrintingExpandedStateForPrint
#               PMPrintingExpandedStateForPrint2
# Domain:       NSGlobalDomain
# Description:  Controls whether the Print dialog box is expanded by default,
#               showing all print options instead of a simplified view. The
#               expanded view provides access to paper size, orientation,
#               scaling, and application-specific print options.
# Default:      false (condensed view with basic options only)
# Options:      true  = Show expanded view with all print options
#               false = Show condensed view with basic options
# Set to:       true (full options for precise print control)
# UI Location:  File > Print (⌘P) dialog - click "Show Details"
# Source:       https://support.apple.com/guide/mac-help/print-documents-mchlp1037/mac
# Note:         Two keys are used for compatibility across different macOS
#               versions. Both should be set to ensure the setting works.
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
#               from the internet. This is part of macOS's malware protection
#               system that flags downloaded files with a quarantine attribute.
# Default:      true (quarantine enabled - warning shown for downloads)
# Options:      true  = Show quarantine warning for downloaded apps
#               false = Suppress quarantine warning (apps open directly)
# Set to:       false (disable warning for power users)
# UI Location:  System Settings > Privacy & Security > Security
# Source:       https://support.apple.com/guide/mac-help/open-an-app-from-an-unidentified-developer-mh40616/mac
# See also:     https://support.apple.com/guide/mac-help/protect-your-mac-from-malware-mh40596/mac
# Security:     ⚠️ SECURITY WARNING - This is a power-user setting that
#               reduces security. Only disable if:
#               1. You carefully verify the source of all downloaded apps
#               2. You use antivirus/anti-malware software
#               3. You understand the risks of running unverified code
#               This does NOT affect Gatekeeper or code signing requirements.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set com.apple.LaunchServices preference: 'LSQuarantine' to 'false'"
else
  defaults write com.apple.LaunchServices LSQuarantine -bool false
fi


msg_success "Global UI and UX settings applied."
