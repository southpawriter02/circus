#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: macOS System & Application Settings
#
# This script configures common macOS and application settings for a developer
# environment using the `defaults` command.
#
# ==============================================================================

main() {
  msg_info "Configuring macOS settings for the 'developer' role..."

  # --- Finder Settings ---
  # Show hidden files (files starting with a dot)
  defaults write com.apple.finder AppleShowAllFiles -bool true
  msg_success "Finder: Enabled showing hidden files."

  # Show the path bar at the bottom of Finder windows
  defaults write com.apple.finder ShowPathbar -bool true
  msg_success "Finder: Enabled the path bar."

  # Show all filename extensions
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  msg_success "Finder: Enabled showing all file extensions."

  # --- Keyboard Settings ---
  # Set a fast key repeat rate
  # Normal is 2 (30 ms), 1 is 15ms
  defaults write NSGlobalDomain KeyRepeat -int 1
  msg_success "Keyboard: Set key repeat rate to fast."

  # Set a short delay until key repeat
  # Normal is 15 (225 ms), 10 is 150ms
  defaults write NSGlobalDomain InitialKeyRepeat -int 10
  msg_success "Keyboard: Set a short delay until key repeat."

  # --- Dock Settings ---
  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true
  msg_success "Dock: Enabled autohide."

  # Restart affected applications to apply changes
  msg_info "Restarting Finder and Dock to apply settings..."
  killall Finder
  killall Dock

  msg_success "macOS settings configuration complete."
}

main
