#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Dock Configuration
#
# This script configures settings for the macOS Dock. It is sourced by
# Stage 11 of the main installer. It supports Dry Run mode.
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
# @param $1 The domain (e.g., com.apple.dock)
# @param $2 The key
# @param $3 The type (e.g., -bool, -int, -string)
# @param $4 The value
run_defaults() {
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Dock preference: '$2' to '$4'"
  else
    defaults write "$1" "$2" "$3" "$4"
  fi
}

msg_info "Configuring Dock settings..."

# ------------------------------------------------------------------------------
# Dock Behavior
# ------------------------------------------------------------------------------

# Enable autohiding for the Dock.
run_defaults "com.apple.dock" "autohide" "-bool" "true"

# Set the delay for autohiding to 0 seconds (makes it instant).
run_defaults "com.apple.dock" "autohide-delay" "-float" "0"

# Set the animation time for showing/hiding the Dock to 0.5 seconds.
run_defaults "com.apple.dock" "autohide-time-animation" "-float" "0.5"

# Enable magnification.
run_defaults "com.apple.dock" "magnification" "-bool" "true"

# Set the icon size for Dock items to 36 pixels.
run_defaults "com.apple.dock" "tilesize" "-int" "36"

# Set the magnification icon size to 96 pixels.
run_defaults "com.apple.dock" "largesize" "-int" "96"

# Don't show recent applications in the Dock.
run_defaults "com.apple.dock" "show-recents" "-bool" "false"

# ------------------------------------------------------------------------------
# Apply Changes
# ------------------------------------------------------------------------------

# Changes to the Dock require restarting the Dock process to take effect.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart the Dock to apply changes."
else
  msg_info "Restarting the Dock to apply changes..."
  killall Dock
fi

msg_success "Dock settings applied."
