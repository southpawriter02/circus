#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Work Dock Configuration
#
# This script configures the macOS Dock for the 'work' role.
# It clears all default applications and adds a curated set of work
# applications.
#
# ==============================================================================

main() {
  msg_info "Configuring the Dock for the 'work' role..."

  # Check if dockutil is installed
  if ! command -v dockutil >/dev/null 2>&1; then
    msg_error "dockutil not found. Please ensure it is installed via Homebrew."
    return 1
  fi

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would clear the Dock and add Google Chrome, Slack, and Zoom."
  else
    # Clear all existing items from the Dock
    dockutil --remove all --no-restart
    msg_info "Cleared the Dock."

    # Add the work applications
    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/Applications/Slack.app" --no-restart
    dockutil --add "/Applications/zoom.us.app" --no-restart
    msg_success "Added work applications to the Dock."

    # Restart the Dock to apply changes
    killall Dock
  fi

  msg_success "Dock configuration complete."
}

main
