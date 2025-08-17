#!/usr/bin/env bash

# ==============================================================================
#
# System: macOS Security & Privacy Configuration
#
# ==============================================================================

msg_info "Configuring Security & Privacy settings..."

# --- Screen Saver Security ---
# Require a password immediately after sleep or screen saver begins.
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
msg_success "Screen Saver: Enabled 'require password immediately'."

# --- Firewall Configuration ---
# The following commands require administrator privileges and may prompt for
# your password if the installer is not run as root.

# Enable the built-in macOS application firewall.
# This blocks incoming connections for non-whitelisted apps.
if sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on; then
  msg_success "Firewall: Enabled the built-in application firewall."
else
  msg_error "Firewall: Failed to enable the firewall."
fi

# Enable Stealth Mode.
# This prevents the system from responding to ICMP (ping) requests and other
# probing attempts from the network.
if sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on; then
  msg_success "Firewall: Enabled Stealth Mode."
else
  msg_error "Firewall: Failed to enable Stealth Mode."
fi

msg_success "Security & Privacy settings configured."
