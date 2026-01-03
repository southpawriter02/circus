#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: AirDrop
#
# DESCRIPTION:
#   Configures AirDrop discoverability and behavior. Controls who can see
#   your Mac for file transfers.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Wi-Fi and Bluetooth must be enabled
#
# REFERENCES:
#   - Apple Support: Use AirDrop on your Mac
#     https://support.apple.com/guide/mac-help/use-airdrop-mh35868/mac
#
# DOMAIN:
#   com.apple.sharingd
#
# NOTES:
#   - "Contacts Only" requires both devices signed into iCloud
#   - "Everyone" makes your Mac visible to anyone nearby
#
# ==============================================================================

msg_info "Configuring AirDrop settings..."

# ==============================================================================
# AirDrop Discoverability
# ==============================================================================

# --- AirDrop Discoverability Mode ---
# Key:          DiscoverableMode
# Domain:       com.apple.sharingd
# Description:  Controls who can see your Mac when AirDrop is active.
#               This affects your privacy and security.
# Default:      Contacts Only
# Options:      Off = No one can see your Mac
#               Contacts Only = Only people in your contacts (requires iCloud)
#               Everyone = Anyone nearby can see your Mac
# Set to:       Contacts Only (balanced security)
# UI Location:  Finder > AirDrop > Allow me to be discovered by
# Security:     "Everyone" exposes your Mac to strangers
run_defaults "com.apple.sharingd" "DiscoverableMode" "-string" "Contacts Only"

# ==============================================================================
# AirDrop over Ethernet
# ==============================================================================

# --- Enable AirDrop over Ethernet ---
# Key:          BrowseAllInterfaces
# Domain:       com.apple.NetworkBrowser
# Description:  Allows AirDrop to work over Ethernet on older Macs that don't
#               have native Ethernet AirDrop support.
# Default:      false
# Options:      true = Enable AirDrop over Ethernet
#               false = Wi-Fi/Bluetooth only
# Set to:       true (more flexible)
# Note:         Primarily for older Mac Pros and Mac minis
run_defaults "com.apple.NetworkBrowser" "BrowseAllInterfaces" "-bool" "true"

msg_success "AirDrop settings configured."
msg_info "Note: AirDrop requires Wi-Fi and Bluetooth to be enabled."
