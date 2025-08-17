#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: UI & UX Configuration
#
# This script configures global settings for the macOS user interface and
# user experience. It is sourced by Stage 11 of the main installer.
# It supports Dry Run mode.
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set UI/UX preference: '$key' to '$value'"
  else
    # These are global settings, so we use the NSGlobalDomain.
    defaults write NSGlobalDomain "$key" "$type" "$value"
  fi
}

msg_info "Configuring global UI and UX settings..."

# ------------------------------------------------------------------------------
# General UI/UX Enhancements
# ------------------------------------------------------------------------------

# --- Always Show Scrollbars ---
# Description:  Controls when scrollbars are visible.
# Default:      "WhenScrolling"
# Possible:     "WhenScrolling", "Automatic", "Always"
# Set to:       "Always"
run_defaults "NSGlobalDomain" "AppleShowScrollBars" "-string" "Always"

# --- Expand Save Panel by Default ---
# Description:  Expands the save dialog box by default, showing the full file
#               system navigator instead of a condensed view.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode" "-bool" "true"
run_defaults "NSGlobalDomain" "NSNavPanelExpandedStateForSaveMode2" "-bool" "true"

# --- Expand Print Panel by Default ---
# Description:  Expands the print dialog box by default.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "NSGlobalDomain" "PMPrintingExpandedStateForPrint" "-bool" "true"
run_defaults "NSGlobalDomain" "PMPrintingExpandedStateForPrint2" "-bool" "true"

# --- Disable "App Quarantine" ---
# Description:  Disables the "Are you sure you want to open this application?"
#               dialog for applications downloaded from the internet.
# Default:      false (Quarantine is enabled)
# Possible:     true, false
# Set to:       true (to disable quarantine)
# Note: This is a power-user setting. Only enable if you are confident in the
#       source of your downloaded applications.
run_defaults "com.apple.LaunchServices" "LSQuarantine" "-bool" "false"


msg_success "Global UI and UX settings applied."
