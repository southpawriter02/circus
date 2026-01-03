#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Sharing Services
#
# DESCRIPTION:
#   Configures macOS sharing services including SSH, Screen Sharing, and
#   File Sharing. Manages remote access and local network sharing options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Administrator privileges for enabling some services
#
# REFERENCES:
#   - Apple Support: Set up file sharing on Mac
#     https://support.apple.com/guide/mac-help/set-up-file-sharing-mh17131/mac
#
# DOMAIN:
#   /var/db/launchd.db/com.apple.launchd/overrides.plist
#   com.apple.screensharing
#
# NOTES:
#   - Enabling services may require confirming in System Preferences
#   - SSH is managed by Remote Login in System Preferences
#
# ==============================================================================

msg_info "Configuring sharing services..."

# ==============================================================================
# Remote Login (SSH)
# ==============================================================================

# Note: SSH (Remote Login) is best managed via:
#   sudo systemsetup -setremotelogin on
#   sudo systemsetup -setremotelogin off
# This requires admin privileges and is typically done interactively

msg_info "SSH/Remote Login: Use 'sudo systemsetup -setremotelogin on|off'"

# ==============================================================================
# Screen Sharing
# ==============================================================================

# --- Screen Sharing VNC Legacy Mode ---
# Key:          VNCLegacyConnectionsEnabled
# Domain:       com.apple.screensharing
# Description:  Allow legacy VNC viewers to connect. Newer clients use
#               Apple Remote Desktop protocol which is more secure.
# Default:      false
# Options:      true = Allow VNC connections
#               false = Disable VNC (ARD only)
# Set to:       false (more secure)
# UI Location:  System Settings > General > Sharing > Screen Sharing > Computer Settings
run_defaults "com.apple.ScreenSharing" "VNCLegacyConnectionsEnabled" "-bool" "false"

# ==============================================================================
# File Sharing
# ==============================================================================

# --- Show Connected Servers on Desktop ---
# Key:          ShowMountedServersOnDesktop
# Domain:       com.apple.finder
# Description:  Show network volumes on the desktop when connected.
# Default:      true
# Note:         This is configured in finder.sh

# --- SMB Signing ---
# Note: SMB packet signing is configured in /etc/nsmb.conf

# ==============================================================================
# AirDrop Settings (moved to separate airdrop.sh)
# ==============================================================================

msg_info "For AirDrop settings, see airdrop.sh"

# ==============================================================================
# Printer Sharing
# ==============================================================================

# Note: Printer sharing is managed via:
#   cupsctl --share-printers
#   cupsctl --no-share-printers

msg_success "Sharing services configured."
