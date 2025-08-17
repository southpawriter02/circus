#!/usr/bin/env bash

# ==============================================================================
#
# System: macOS Finder Configuration
#
# ==============================================================================

msg_info "Configuring Finder settings..."

# Show hidden files (files starting with a dot)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show the path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

msg_success "Finder settings configured."
