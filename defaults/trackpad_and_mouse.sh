#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Trackpad & Mouse Configuration
#
# This script configures settings for the Trackpad and Mouse.
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
    msg_info "[Dry Run] Would set Trackpad/Mouse preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Trackpad and Mouse settings..."

# ------------------------------------------------------------------------------
# Trackpad Settings
# ------------------------------------------------------------------------------

# --- Enable Tap to Click ---
# Description:  Enables the "Tap to click" feature for the current user.
# Default:      0 (false)
# Possible:     1 (true), 0 (false)
# Set to:       1 (true)
run_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "-int" "1"
run_defaults "com.apple.AppleMultitouchTrackpad" "Clicking" "-int" "1"

# --- Set Trackpad Tracking Speed ---
# Description:  Sets the tracking speed of the trackpad.
# Default:      1.0
# Possible:     A float value, where higher is faster.
# Set to:       2.0 (a moderately fast setting)
run_defaults "NSGlobalDomain" "com.apple.trackpad.scaling" "-float" "2.0"


# ------------------------------------------------------------------------------
# Mouse Settings
# ------------------------------------------------------------------------------

# --- Set Mouse Tracking Speed ---
# Description:  Sets the tracking speed of the mouse.
# Default:      1.0
# Possible:     A float value, where higher is faster.
# Set to:       2.0 (a moderately fast setting)
run_defaults "NSGlobalDomain" "com.apple.mouse.scaling" "-float" "2.0"


# ------------------------------------------------------------------------------
# Scrolling Behavior (Applies to both Trackpad and Mouse)
# ------------------------------------------------------------------------------

# --- Disable "Natural" Scrolling ---
# Description:  Disables the "natural" scrolling direction, where content moves with
#               your fingers. When disabled, the scrollbar moves with your fingers.
# Default:      true
# Possible:     true, false
# Set to:       false
run_defaults "NSGlobalDomain" "com.apple.swipescrolldirection" "-bool" "false"


msg_success "Trackpad and Mouse settings applied. A restart may be required for all changes to take effect."
