#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Pages Configuration
#
# DESCRIPTION:
#   This script configures Apple Pages preferences including document defaults,
#   editing behavior, and author information. Pages is Apple's word processing
#   application, part of the iWork suite.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Pages app installed (free from App Store)
#
# REFERENCES:
#   - Apple Support: Pages User Guide
#     https://support.apple.com/guide/pages/welcome/mac
#   - Apple Support: Change Pages settings
#     https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
#
# DOMAIN:
#   com.apple.iWork.Pages
#
# NOTES:
#   - Pages preferences stored in ~/Library/Preferences/com.apple.iWork.Pages.plist
#   - Documents can sync via iCloud Drive
#   - Supports import/export of Word documents
#   - Author name is used for comments and track changes
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Pages preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Pages settings..."

# ==============================================================================
# General Settings
# ==============================================================================

# --- Default Template ---
# Key:          TSADefaultTemplate
# Domain:       com.apple.iWork.Pages
# Description:  Controls whether new documents start from a template chooser
#               or use a default blank template.
# Default:      (uses template chooser)
# Note:         Template selection is better configured in-app
# UI Location:  Pages > Settings > General > For New Documents
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac

# --- Default Zoom Level ---
# Key:          TSDefaultZoom
# Domain:       com.apple.iWork.Pages
# Description:  Sets the default zoom level for new documents.
# Default:      125 (125%)
# Options:      25-400 (percentage)
# Set to:       100 (actual size)
# UI Location:  View > Zoom
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSDefaultZoom" "-int" "100"

# ==============================================================================
# Editing Settings
# ==============================================================================

# --- Show Guides at Object Center ---
# Key:          TSShowsObjectCenterGuides
# Domain:       com.apple.iWork.Pages
# Description:  Shows alignment guides when dragging objects near the center
#               of other objects, helping with precise positioning.
# Default:      true
# Options:      true  = Show center alignment guides
#               false = Hide center guides
# Set to:       true (precise alignment)
# UI Location:  Pages > Settings > Rulers
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSShowsObjectCenterGuides" "-bool" "true"

# --- Show Guides at Object Edges ---
# Key:          TSShowsObjectEdgeGuides
# Domain:       com.apple.iWork.Pages
# Description:  Shows alignment guides when dragging objects near the edges
#               of other objects for precise edge alignment.
# Default:      true
# Options:      true  = Show edge alignment guides
#               false = Hide edge guides
# Set to:       true (precise alignment)
# UI Location:  Pages > Settings > Rulers
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSShowsObjectEdgeGuides" "-bool" "true"

# --- Show Size and Position When Moving Objects ---
# Key:          TSShowSizeAndPositionWhenMoving
# Domain:       com.apple.iWork.Pages
# Description:  Displays a tooltip showing object size and position while
#               dragging objects in the document.
# Default:      true
# Options:      true  = Show size/position info
#               false = Hide info during drag
# Set to:       true (precise positioning)
# UI Location:  Pages > Settings > Rulers
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSShowSizeAndPositionWhenMoving" "-bool" "true"

# ==============================================================================
# Text Settings
# ==============================================================================

# --- Smart Quotes ---
# Key:          TSWPUseSmartQuotes
# Domain:       com.apple.iWork.Pages
# Description:  Automatically converts straight quotes to curly typographic
#               quotes as you type.
# Default:      true
# Options:      true  = Use smart quotes
#               false = Use straight quotes
# Set to:       true (professional typography)
# UI Location:  Edit > Substitutions > Smart Quotes
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSWPUseSmartQuotes" "-bool" "true"

# --- Smart Dashes ---
# Key:          TSWPUseSmartDashes
# Domain:       com.apple.iWork.Pages
# Description:  Automatically converts double hyphens to em-dashes and handles
#               en-dashes appropriately.
# Default:      true
# Options:      true  = Use smart dashes
#               false = Use regular dashes
# Set to:       true (professional typography)
# UI Location:  Edit > Substitutions > Smart Dashes
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSWPUseSmartDashes" "-bool" "true"

# ==============================================================================
# View Settings
# ==============================================================================

# --- Show Word Count ---
# Key:          TSWPShowWordCount
# Domain:       com.apple.iWork.Pages
# Description:  Displays the word count at the bottom of the document window
#               for easy reference while writing.
# Default:      false
# Options:      true  = Show word count
#               false = Hide word count
# Set to:       true (useful for writing)
# UI Location:  View > Show Word Count
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSWPShowWordCount" "-bool" "true"

# --- Show Invisibles ---
# Key:          TSWPShowInvisibles
# Domain:       com.apple.iWork.Pages
# Description:  Shows invisible characters like spaces, tabs, and paragraph
#               marks to help with formatting.
# Default:      false
# Options:      true  = Show invisible characters
#               false = Hide invisibles
# Set to:       false (cleaner view by default)
# UI Location:  View > Show Invisibles
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "TSWPShowInvisibles" "-bool" "false"

# ==============================================================================
# Auto-Save and Versions
# ==============================================================================

# --- Auto-Save ---
# Key:          NSDocumentSavesInPlace
# Domain:       com.apple.iWork.Pages
# Description:  Enables automatic saving of documents. With auto-save, your
#               work is continuously saved as you edit.
# Default:      true
# Options:      true  = Auto-save enabled
#               false = Manual save only
# Set to:       true (never lose work)
# UI Location:  System-wide preference, respects macOS settings
# Source:       https://support.apple.com/guide/pages/change-settings-tanf9f2cc8d6/mac
run_defaults "com.apple.iWork.Pages" "NSDocumentSavesInPlace" "-bool" "true"

# ==============================================================================
# Author Information
# ==============================================================================

# Note: Author name for comments and track changes is configured in-app:
# Pages > Settings > General > Author
# This uses the system user name by default.

msg_success "Pages settings applied."
msg_info "Configure your author name in Pages > Settings > General > Author."
