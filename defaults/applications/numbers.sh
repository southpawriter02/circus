#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Numbers Configuration
#
# DESCRIPTION:
#   This script configures Apple Numbers preferences including calculation
#   settings, cell formatting options, and editing behavior. Numbers is
#   Apple's spreadsheet application, part of the iWork suite.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Numbers app installed (free from App Store)
#
# REFERENCES:
#   - Apple Support: Numbers User Guide
#     https://support.apple.com/guide/numbers/welcome/mac
#   - Apple Support: Change Numbers settings
#     https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
#
# DOMAIN:
#   com.apple.iWork.Numbers
#
# NOTES:
#   - Numbers preferences stored in ~/Library/Preferences/com.apple.iWork.Numbers.plist
#   - Spreadsheets can sync via iCloud Drive
#   - Supports import/export of Excel files
#   - Templates are stored in ~/Library/Containers/com.apple.iWork.Numbers/
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Numbers preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Numbers settings..."

# ==============================================================================
# General Settings
# ==============================================================================

# --- Default Template ---
# Key:          TSADefaultTemplate
# Domain:       com.apple.iWork.Numbers
# Description:  Controls whether new spreadsheets start from a template chooser
#               or use a default blank template.
# Default:      (uses template chooser)
# Note:         Template selection is better configured in-app
# UI Location:  Numbers > Settings > General > For New Documents
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac

# ==============================================================================
# Editing Settings
# ==============================================================================

# --- Show Tab Key Inserts Tab ---
# Key:          TSInsertTabInsteadOfMoving
# Domain:       com.apple.iWork.Numbers
# Description:  Controls whether Tab key inserts a tab character in cells or
#               moves to the next cell.
# Default:      false (Tab moves to next cell)
# Options:      true  = Tab inserts tab character
#               false = Tab moves to next cell
# Set to:       false (standard spreadsheet behavior)
# UI Location:  Numbers > Settings > General
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "TSInsertTabInsteadOfMoving" "-bool" "false"

# --- Show Guides at Object Center ---
# Key:          TSShowsObjectCenterGuides
# Domain:       com.apple.iWork.Numbers
# Description:  Shows alignment guides when dragging objects near the center
#               of other objects, helping with precise positioning.
# Default:      true
# Options:      true  = Show center alignment guides
#               false = Hide center guides
# Set to:       true (precise alignment)
# UI Location:  Numbers > Settings > Rulers
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "TSShowsObjectCenterGuides" "-bool" "true"

# --- Show Guides at Object Edges ---
# Key:          TSShowsObjectEdgeGuides
# Domain:       com.apple.iWork.Numbers
# Description:  Shows alignment guides when dragging objects near the edges
#               of other objects for precise edge alignment.
# Default:      true
# Options:      true  = Show edge alignment guides
#               false = Hide edge guides
# Set to:       true (precise alignment)
# UI Location:  Numbers > Settings > Rulers
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "TSShowsObjectEdgeGuides" "-bool" "true"

# ==============================================================================
# Calculation Settings
# ==============================================================================

# --- Date Calculations Use 1904 Date System ---
# Key:          Use1904DateSystem
# Domain:       com.apple.iWork.Numbers
# Description:  Controls the date system used for calculations. The 1904 date
#               system is compatible with older Mac software, while 1900 is
#               compatible with Windows Excel.
# Default:      false (1900 date system)
# Options:      true  = Use 1904 date system
#               false = Use 1900 date system (Excel compatible)
# Set to:       false (Excel compatibility)
# UI Location:  Per-document setting
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "Use1904DateSystem" "-bool" "false"

# ==============================================================================
# Auto-Save and Versions
# ==============================================================================

# --- Auto-Save ---
# Key:          NSDocumentSavesInPlace
# Domain:       com.apple.iWork.Numbers
# Description:  Enables automatic saving of spreadsheets. With auto-save,
#               your work is continuously saved as you edit.
# Default:      true
# Options:      true  = Auto-save enabled
#               false = Manual save only
# Set to:       true (never lose work)
# UI Location:  System-wide preference, respects macOS settings
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "NSDocumentSavesInPlace" "-bool" "true"

# ==============================================================================
# Warning Settings
# ==============================================================================

# --- Show Formula Warnings ---
# Key:          TSShowFormulaWarnings
# Domain:       com.apple.iWork.Numbers
# Description:  Displays warnings in cells when formula issues are detected,
#               such as division by zero or circular references.
# Default:      true
# Options:      true  = Show formula warnings
#               false = Hide warnings
# Set to:       true (catch errors early)
# UI Location:  Numbers > Settings > General
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "TSShowFormulaWarnings" "-bool" "true"

# --- Warn Before Deleting Sheets ---
# Key:          TSWarnBeforeDeletingSheets
# Domain:       com.apple.iWork.Numbers
# Description:  Shows a confirmation dialog before deleting sheets to prevent
#               accidental data loss.
# Default:      true
# Options:      true  = Ask before deleting
#               false = Delete without confirmation
# Set to:       true (prevent accidental deletion)
# UI Location:  Implicit behavior
# Source:       https://support.apple.com/guide/numbers/change-settings-tan6df912ce5/mac
run_defaults "com.apple.iWork.Numbers" "TSWarnBeforeDeletingSheets" "-bool" "true"

msg_success "Numbers settings applied."
