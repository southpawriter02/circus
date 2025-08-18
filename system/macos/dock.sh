#!/usr/bin/env bash

# ==============================================================================
#
# System: macOS Dock Configuration
#
# ==============================================================================

msg_info "Configuring Dock settings..."

# Automatically hide and show the Dock
run_defaults write com.apple.dock autohide -bool true

msg_success "Dock settings configured."
