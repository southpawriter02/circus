#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: TextEdit Configuration
#
# This script configures settings for the TextEdit application to make it more
# suitable for plain text and code editing.
# It is sourced by Stage 11 of the main installer. It supports Dry Run mode.
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set TextEdit preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring TextEdit settings..."

# ------------------------------------------------------------------------------
# Document Format and Behavior
# ------------------------------------------------------------------------------

# --- Default to Plain Text Mode ---
# Description:  Sets the default document format to plain text instead of Rich Text Format (RTF).
# Default:      "RTF"
# Possible:     "RTF", "Plain"
# Set to:       "Plain"
run_defaults "com.apple.TextEdit" "RichText" "-int" "0"

# --- Disable Smart Quotes ---
# Description:  Prevents the automatic substitution of straight quotes with curly (typographic) quotes.
# Default:      true
# Possible:     true, false
# Set to:       false
run_defaults "com.apple.TextEdit" "SmartQuotes" "-bool" "false"

# --- Disable Smart Dashes ---
# Description:  Prevents the automatic substitution of hyphens with en/em dashes.
# Default:      true
# Possible:     true, false
# Set to:       false
run_defaults "com.apple.TextEdit" "SmartDashes" "-bool" "false"

# ------------------------------------------------------------------------------
# Font and Window Settings
# ------------------------------------------------------------------------------

# --- Set Default Plain Text Font ---
# Description:  Sets the default font and size for plain text documents.
# Default:      "Menlo-Regular 11"
# Possible:     Any valid font name and size string.
# Set to:       "FiraCode-Retina 13" (A modern, legible coding font)
run_defaults "com.apple.TextEdit" "NSFixedPitchFont" "-string" "FiraCode-Retina"
run_defaults "com.apple.TextEdit" "NSFixedPitchFontSize" "-int" "13"

# --- Set Default Window Size ---
# Description:  Sets the default size for new TextEdit windows.
# Default:      Varies
# Possible:     An array of two integers for width and height.
# Set to:       A reasonable size of 900x600 pixels.
# Note: This requires a more complex type, so we don't use the helper.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would set TextEdit preference: 'WinV' to '(900, 600)'"
else
  defaults write com.apple.TextEdit WinV -string "(900, 600)"
fi


msg_success "TextEdit settings applied."
