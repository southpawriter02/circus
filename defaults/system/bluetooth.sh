#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Bluetooth Settings
#
# DESCRIPTION:
#   Configures Bluetooth preferences including discoverability, menu bar icon,
#   and device connection behavior.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Bluetooth hardware (built-in or USB adapter)
#
# REFERENCES:
#   - Apple Support: Use Bluetooth on your Mac
#     https://support.apple.com/en-us/HT201171
#   - Apple Support: Bluetooth settings on Mac
#     https://support.apple.com/guide/mac-help/bluetooth-settings-mchlp3013/mac
#
# DOMAIN:
#   com.apple.Bluetooth
#   com.apple.controlcenter
#
# NOTES:
#   - Some settings require Bluetooth to be turned on
#   - Discoverability should be disabled when not pairing new devices
#   - blueutil CLI tool can be used for scripting Bluetooth
#
# ==============================================================================

msg_info "Configuring Bluetooth settings..."

# ==============================================================================
# Menu Bar
# ==============================================================================

# --- Show Bluetooth in Menu Bar ---
# Key:          Bluetooth
# Domain:       com.apple.controlcenter
# Description:  Controls whether the Bluetooth icon appears in the menu bar.
#               The icon provides quick access to Bluetooth devices and settings.
# Default:      18 (shown in Control Center, sometimes in menu bar)
# Options:      2 = Always show in menu bar
#               8 = Show when active
#               18 = Show in Control Center (default)
#               24 = Don't show
# Set to:       2 (always show in menu bar for quick access)
# UI Location:  System Settings > Control Center > Bluetooth
run_defaults "com.apple.controlcenter" "Bluetooth" "-int" "2"

# ==============================================================================
# Discoverability
#
# NOTE: Bluetooth discoverability is handled differently in modern macOS.
# The system automatically manages discoverability:
# - When Bluetooth preferences pane is open, Mac is discoverable
# - When pairing mode is active, Mac is discoverable
# - Otherwise, Mac is not discoverable to new devices
#
# The old DiscoverableState key is deprecated. Modern macOS uses:
# - System Settings > Bluetooth to manage pairing
#
# For security, you generally don't need to change this behavior.
# The Mac becomes discoverable only when you're actively in Bluetooth settings.
#
# ==============================================================================

# ==============================================================================
# Audio Codec Settings
# ==============================================================================

# --- Increase Bluetooth Audio Quality ---
# Key:          Apple Bitpool Min (editable)
# Domain:       com.apple.BluetoothAudioAgent
# Description:  Controls the minimum bitpool for A2DP Bluetooth audio.
#               Higher values can improve audio quality at the cost of
#               connection stability.
# Default:      2
# Options:      2 (conservative) to 64 (highest quality)
# Set to:       40 (good balance of quality and stability)
# Note:         This affects all Bluetooth audio devices
# Warning:      Very high values may cause audio dropouts
run_defaults "com.apple.BluetoothAudioAgent" "Apple Bitpool Min (editable)" "-int" "40"

# ==============================================================================
# Device Behavior
#
# NOTE: The following settings are controlled via System Settings UI:
#
# - Allow Handoff between this Mac and your iCloud devices
#   System Settings > General > AirDrop & Handoff
#
# - Allow Bluetooth devices to wake this computer
#   System Settings > Bluetooth > Advanced
#
# - Open Bluetooth Setup Assistant if no keyboard is detected
#   System Settings > Bluetooth > Advanced
#
# These settings don't have reliable defaults keys and should be
# configured through the UI or MDM profiles.
#
# ==============================================================================

# ==============================================================================
# Command Line Tools
#
# For advanced Bluetooth control, consider installing blueutil:
#   brew install blueutil
#
# Common blueutil commands:
#   blueutil --power 1              # Turn Bluetooth on
#   blueutil --power 0              # Turn Bluetooth off
#   blueutil --discoverable 1       # Enable discoverability
#   blueutil --discoverable 0       # Disable discoverability
#   blueutil --paired               # List paired devices
#   blueutil --connected            # List connected devices
#   blueutil --connect XX-XX-XX     # Connect to device by MAC
#   blueutil --disconnect XX-XX-XX  # Disconnect device
#
# System commands:
#   system_profiler SPBluetoothDataType  # Detailed Bluetooth info
#
# ==============================================================================

msg_success "Bluetooth settings configured."
