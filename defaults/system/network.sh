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
# Description:  Controls whether Bonjour (zero-configuration networking) browses
#               for services across all network interfaces. When enabled, your Mac
#               can discover printers, file shares, AirPlay devices, and other
#               Bonjour-advertised services on any connected network (Wi-Fi,
#               Ethernet, Thunderbolt Bridge, etc.).
# Default:      true (browse all interfaces)
# Options:      true = Discover Bonjour services on all connected networks
#               false = Limited Bonjour browsing (primary interface only)
# Set to:       true (ensures comprehensive service discovery across all networks;
#               essential for multi-interface setups like docked laptops)
# UI Location:  Not exposed in System Settings UI; command-line only
# Source:       https://support.apple.com/guide/mac-help/bonjour-mchlp1011/mac
# See also:     https://developer.apple.com/bonjour/
run_defaults "com.apple.NetworkBrowser" "BrowseAllInterfaces" "-bool" "true"

# ==============================================================================
# Wake-on-LAN
# ==============================================================================

# --- Wake for Network Access ---
# Key:          womp (via pmset, not defaults)
# Description:  Allows the Mac to wake from sleep when it receives a Wake-on-LAN
#               (WoL) magic packet. Useful for remote access and management.
# Default:      1 on desktop Macs, 0 on laptops (battery conservation)
# Options:      1 = Enable Wake-on-LAN
#               0 = Disable Wake-on-LAN
# UI Location:  System Settings > Energy Saver > Wake for network access
# Source:       https://support.apple.com/guide/mac-help/mchlp1205/mac
# Note:         Use pmset command instead of defaults:
#                 sudo pmset -a womp 1   # Enable Wake-on-LAN
#                 sudo pmset -a womp 0   # Disable Wake-on-LAN

msg_info "Wake-on-LAN: Use 'sudo pmset -a womp 1|0'"

# ==============================================================================
# Bonjour Sleep Proxy
# ==============================================================================

# --- Disable Bonjour Multicast Advertisements ---
# Key:          NoMulticastAdvertisements
# Domain:       com.apple.mDNSResponder
# Description:  Controls whether mDNSResponder sends multicast DNS advertisements
#               when the Mac is sleeping via a Bonjour Sleep Proxy. When disabled
#               (the default), an Apple TV or AirPort base station acting as a
#               sleep proxy can respond to Bonjour queries on behalf of your
#               sleeping Mac, enabling features like Back to My Mac and AirPlay.
# Default:      false (allow multicast advertisements via sleep proxy)
# Options:      true = Disable multicast advertisements (breaks sleep proxy)
#               false = Allow multicast advertisements (enables sleep proxy)
# Set to:       false (preserves Bonjour functionality; AirDrop, AirPlay, printer
#               discovery, and Wake-on-Demand all depend on mDNS)
# UI Location:  Not exposed in System Settings UI; command-line only
# Source:       https://developer.apple.com/library/archive/qa/qa1312/_index.html
# Security:     Enabling (true) can improve privacy by preventing your Mac from
#               being discoverable while sleeping, but breaks many macOS features.
# See also:     man mDNSResponder
run_defaults "com.apple.mDNSResponder" "NoMulticastAdvertisements" "-bool" "false"

# ==============================================================================
# mDNS (Multicast DNS)
# ==============================================================================

# Note: To completely disable mDNS:
#   sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
# Warning: This breaks Bonjour, AirDrop, AirPlay, and many other services

msg_success "Network settings configured."
