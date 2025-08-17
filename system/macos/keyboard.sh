#!/usr/bin/env bash

# ==============================================================================
#
# System: macOS Keyboard Configuration
#
# ==============================================================================

msg_info "Configuring keyboard settings..."

# Set a fast key repeat rate
# Normal is 2 (30 ms), 1 is 15ms
defaults write NSGlobalDomain KeyRepeat -int 1

# Set a short delay until key repeat
# Normal is 15 (225 ms), 10 is 150ms
defaults write NSGlobalDomain InitialKeyRepeat -int 10

msg_success "Keyboard settings configured."
