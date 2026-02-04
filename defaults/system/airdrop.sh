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
# Description:  Controls who can discover your Mac when AirDrop is active in
#               Finder or Control Center. This setting directly affects your
#               privacy and potential exposure to unsolicited file transfers.
#               AirDrop uses Bluetooth for device discovery and Wi-Fi for the
#               actual file transfer, creating a peer-to-peer connection.
# Default:      Contacts Only (requires iCloud sign-in on both devices)
# Options:      Off = No one can see your Mac via AirDrop
#               Contacts Only = Only people in your Contacts app (requires iCloud)
#               Everyone = Anyone with AirDrop enabled nearby can see your Mac
# Set to:       Contacts Only (balanced security - prevents spam from strangers
#               while allowing easy sharing with known contacts)
# UI Location:  Finder > AirDrop > Allow me to be discovered by
#               Control Center > AirDrop > Contacts Only/Everyone/Off
# Source:       https://support.apple.com/guide/mac-help/use-airdrop-mh35868/mac
# Security:     "Everyone" exposes your Mac to strangers who can send unsolicited
#               files. In public spaces, this can lead to AirDrop spam or
#               inappropriate content. Use "Contacts Only" or "Off" in public.
# See also:     https://support.apple.com/en-us/102766
run_defaults "com.apple.sharingd" "DiscoverableMode" "-string" "Contacts Only"

# ==============================================================================
# AirDrop over Ethernet
# ==============================================================================

# --- Enable AirDrop over Ethernet ---
# Key:          BrowseAllInterfaces
# Domain:       com.apple.NetworkBrowser
# Description:  Enables AirDrop functionality over Ethernet connections on Macs
#               that don't have built-in Wi-Fi/Bluetooth AirDrop support. This
#               extends Bonjour browsing to all network interfaces, allowing
#               wired-only Macs to participate in AirDrop file transfers.
# Default:      false (Wi-Fi/Bluetooth interfaces only)
# Options:      true = Enable AirDrop discovery over all interfaces (incl. Ethernet)
#               false = Standard Wi-Fi/Bluetooth discovery only
# Set to:       true (enables AirDrop on older Mac Pros and Mac minis that rely
#               on Ethernet; no negative impact on Macs with Wi-Fi)
# UI Location:  Not exposed in System Settings UI; command-line only
# Source:       https://support.apple.com/en-us/101655
# Note:         Primarily benefits pre-2012 Mac Pros and Mac minis without
#               802.11ac Wi-Fi. Modern Macs ignore this setting.
run_defaults "com.apple.NetworkBrowser" "BrowseAllInterfaces" "-bool" "true"

msg_success "AirDrop settings configured."
msg_info "Note: AirDrop requires Wi-Fi and Bluetooth to be enabled."
