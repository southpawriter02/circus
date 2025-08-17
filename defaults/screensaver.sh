#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Screensaver Configuration
#
# This script configures settings for the macOS screensaver and screen lock.
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
    msg_info "[Dry Run] Would set Screensaver preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Screensaver settings..."

# ------------------------------------------------------------------------------
# Screen Lock Settings
# ------------------------------------------------------------------------------

# --- Require Password Immediately ---
# Description:  Controls whether a password is required to exit the screensaver or
#               wake the display. This is a critical security setting.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- Password Delay ---
# Description:  Sets the delay (in seconds) after the screensaver begins before
#               a password is required.
# Default:      5
# Possible:     An integer representing seconds.
# Set to:       0 (Require password immediately with no grace period).
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"


# ------------------------------------------------------------------------------
# Screensaver Idle Time
# ------------------------------------------------------------------------------

# --- Idle Time Before Start ---
# Description:  Sets the idle time (in seconds) before the screensaver starts.
# Default:      1200 (20 minutes)
# Possible:     An integer representing seconds. 0 disables the screensaver.
# Set to:       600 (10 minutes)
run_defaults "com.apple.screensaver" "idleTime" "-int" "600"


msg_success "Screensaver settings applied."
