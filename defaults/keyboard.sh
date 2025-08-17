#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Keyboard Configuration
#
# This script configures settings for the keyboard, such as key repeat rate.
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
    msg_info "[Dry Run] Would set Keyboard preference: '$key' to '$value'"
  else
    # These settings are global, so we use the NSGlobalDomain.
    defaults write NSGlobalDomain "$key" "$type" "$value"
  fi
}

msg_info "Configuring Keyboard settings..."

# ------------------------------------------------------------------------------
# Key Repeat Settings
# ------------------------------------------------------------------------------

# --- Key Repeat Rate ---
# Description:  Controls the speed at which a character repeats when a key is held down.
# Default:      2 (which corresponds to 30ms).
# Possible:     A range from 0 to 100. Lower numbers are faster. A value of 2 is fast, 1 is very fast.
# Set to:       1 (The fastest possible setting without using custom values).
run_defaults "NSGlobalDomain" "KeyRepeat" "-int" "1"

# --- Delay Until Repeat ---
# Description:  Controls the delay (in milliseconds) before key repeat begins.
# Default:      15 (which corresponds to 225ms).
# Possible:     A range from 0 to 100. Lower numbers are shorter delays.
# Set to:       10 (A very short delay).
run_defaults "NSGlobalDomain" "InitialKeyRepeat" "-int" "10"


# ------------------------------------------------------------------------------
# Other Keyboard Settings
# ------------------------------------------------------------------------------

# --- Full Keyboard Access ---
# Description:  Enables full keyboard access for all controls (e.g., allows you to
#               use the Tab key to navigate between buttons in dialog boxes).
# Default:      Varies by macOS version, but often off by default.
# Possible:     0 (Text boxes and lists only), 2 (All controls).
# Set to:       2
run_defaults "NSGlobalDomain" "AppleKeyboardUIMode" "-int" "2"


msg_success "Keyboard settings applied. Note: A restart is required for these changes to take full effect."
