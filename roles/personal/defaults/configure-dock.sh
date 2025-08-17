#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Personal Dock Configuration
#
# This script configures the macOS Dock for the 'personal' role.
# It clears all default applications and adds a curated set of personal
# applications.
#
# ==============================================================================

main() {
  msg_info "Configuring the Dock for the 'personal' role..."

  # Check if dockutil is installed
  if ! command -v dockutil >/dev/null 2>&1; then
    msg_error "dockutil not found. Please ensure it is installed via Homebrew."
    return 1
  fi

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would clear the Dock and add Google Chrome, Spotify, and VLC."
  else
    # Clear all existing items from the Dock
    dockutil --remove all --no-restart
    msg_info "Cleared the Dock."

    # Add the personal applications
    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/Applications/Spotify.app" --no-restart
    dockutil --add "/Applications/VLC.app" --no-restart
    msg_success "Added personal applications to the Dock."

    # Restart the Dock to apply changes
    killall Dock
  fi

  msg_success "Dock configuration complete."
}

main
