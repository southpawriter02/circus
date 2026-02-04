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

# --- Remote Login (SSH) ---
# Key:          N/A (managed via systemsetup, not defaults)
# Description:  Enables SSH access to your Mac, allowing secure remote terminal
#               connections. When enabled, authorized users can connect via the
#               `ssh` command from any network location. Access is controlled by
#               user/group settings in System Settings.
# Default:      Off (disabled for security)
# Options:      On = Enable SSH server (sshd)
#               Off = Disable SSH server
# UI Location:  System Settings > General > Sharing > Remote Login
# Source:       https://support.apple.com/guide/mac-help/allow-a-remote-computer-to-access-your-mac-mchlp1066/mac
# Security:     Enabling SSH exposes your Mac to potential brute-force attacks.
#               Use strong passwords or SSH keys. Consider limiting to specific
#               users and using non-standard ports for public-facing Macs.
# Note:         Use systemsetup command instead of defaults:
#                 sudo systemsetup -setremotelogin on   # Enable SSH
#                 sudo systemsetup -setremotelogin off  # Disable SSH
# See also:     man sshd_config, man ssh

msg_info "SSH/Remote Login: Use 'sudo systemsetup -setremotelogin on|off'"

# ==============================================================================
# Screen Sharing
# ==============================================================================

# --- Screen Sharing VNC Legacy Mode ---
# Key:          VNCLegacyConnectionsEnabled
# Domain:       com.apple.ScreenSharing
# Description:  Controls whether legacy VNC (Virtual Network Computing) viewers
#               can connect to your Mac. Modern macOS uses the more secure Apple
#               Remote Desktop (ARD) protocol by default. Enabling VNC allows
#               third-party VNC clients (RealVNC, TightVNC, etc.) to connect,
#               but with weaker encryption than ARD.
# Default:      false (ARD protocol only)
# Options:      true = Allow VNC connections (less secure, more compatible)
#               false = Disable VNC, use ARD only (more secure)
# Set to:       false (security-focused; use Apple Remote Desktop or
#               iCloud Screen Sharing for secure remote access)
# UI Location:  System Settings > General > Sharing > Screen Sharing > 
#               (i) button > Computer Settings > VNC viewers may control screen
# Source:       https://support.apple.com/guide/mac-help/share-the-screen-of-another-mac-mh14066/mac
# Security:     VNC uses weaker authentication than ARD. Only enable if you
#               need to connect from non-Apple devices and understand the risks.
# See also:     https://support.apple.com/guide/remote-desktop/welcome/mac
run_defaults "com.apple.ScreenSharing" "VNCLegacyConnectionsEnabled" "-bool" "false"

# ==============================================================================
# File Sharing
# ==============================================================================

# --- Show Connected Servers on Desktop ---
# Key:          ShowMountedServersOnDesktop
# Domain:       com.apple.finder
# Description:  Displays network volumes on the desktop when connected.
# UI Location:  Finder > Settings > General > Show these items on the desktop
# Note:         This setting is configured in finder.sh

# --- SMB Signing ---
# Description:  SMB packet signing provides integrity verification for file
#               sharing connections. Configured via /etc/nsmb.conf, not defaults.
# Source:       https://support.apple.com/en-us/102063
# Note:         Edit /etc/nsmb.conf to configure SMB signing requirements

# ==============================================================================
# AirDrop Settings
# ==============================================================================

# Note: AirDrop configuration has been moved to airdrop.sh for better organization
msg_info "For AirDrop settings, see airdrop.sh"

# ==============================================================================
# Printer Sharing
# ==============================================================================

# --- Printer Sharing ---
# Description:  Allows other computers on your network to use printers connected
#               to this Mac. Managed via CUPS (Common Unix Printing System) rather
#               than defaults write commands.
# UI Location:  System Settings > General > Sharing > Printer Sharing
# Source:       https://support.apple.com/guide/mac-help/share-your-printer-mchl7c5dc1f0/mac
# Note:         Use cupsctl to manage printer sharing:
#                 cupsctl --share-printers      # Enable sharing
#                 cupsctl --no-share-printers   # Disable sharing
# See also:     man cupsctl

msg_success "Sharing services configured."
