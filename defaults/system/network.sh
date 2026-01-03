#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Network Settings
#
# DESCRIPTION:
#   Configures network-related system settings including Wake-on-LAN,
#   Bonjour, and network discovery options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings may require restart
#
# REFERENCES:
#   - Apple Support: Wake your Mac when it's in sleep
#     https://support.apple.com/guide/mac-help/mchlp1205/mac
#
# DOMAIN:
#   com.apple.NetworkBrowser
#   com.apple.mDNSResponder
#
# NOTES:
#   - Wake-on-LAN requires compatible hardware
#   - DNS settings are better managed via networksetup command
#
# ==============================================================================

msg_info "Configuring network settings..."

# ==============================================================================
# Network Discovery
# ==============================================================================

# --- Bonjour Discovery ---
# Key:          BrowseAllInterfaces
# Domain:       com.apple.NetworkBrowser
# Description:  Controls Bonjour browsing across all network interfaces.
#               Enables discovery of services on all connected networks.
# Default:      true
# Options:      true = Browse all interfaces
#               false = Limited browsing
run_defaults "com.apple.NetworkBrowser" "BrowseAllInterfaces" "-bool" "true"

# ==============================================================================
# Wake-on-LAN
# ==============================================================================

# --- Wake for Network Access ---
# Note: This is best managed via System Preferences > Energy Saver
#       or via pmset command:
#   sudo pmset -a womp 1   # Enable Wake-on-LAN
#   sudo pmset -a womp 0   # Disable Wake-on-LAN

msg_info "Wake-on-LAN: Use 'sudo pmset -a womp 1|0'"

# ==============================================================================
# Bonjour Sleep Proxy
# ==============================================================================

# --- Disable Bonjour Sleep Proxy ---
# Key:          NoMulticastAdvertisements
# Domain:       com.apple.mDNSResponder
# Description:  Controls Bonjour multicast advertisements when sleeping.
#               Disabling can improve network security but breaks some features.
# Default:      false (allow advertisements)
# Options:      true = Disable multicast ads
#               false = Allow multicast ads
# Set to:       false (keep Bonjour working)
run_defaults "com.apple.mDNSResponder" "NoMulticastAdvertisements" "-bool" "false"

# ==============================================================================
# mDNS (Multicast DNS)
# ==============================================================================

# Note: To completely disable mDNS:
#   sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
# Warning: This breaks Bonjour, AirDrop, AirPlay, and many other services

msg_success "Network settings configured."
