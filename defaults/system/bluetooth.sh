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

# Bluetooth Audio Codec Overview:
#
# macOS uses A2DP (Advanced Audio Distribution Profile) for high-quality
# stereo audio streaming to headphones and speakers. Within A2DP, the actual
# audio encoding uses one of several codecs:
#
# CODEC            QUALITY    LATENCY    SUPPORT
# ─────────────────────────────────────────────────────
# SBC (default)    Moderate   ~200ms     Universal (all devices)
# AAC              Good       ~120ms     Apple devices, some others
# aptX             Good       ~70ms      Qualcomm devices (not Apple Silicon)
# LDAC             Excellent  ~200ms     Sony devices (limited macOS support)
#
# macOS on Apple Silicon primarily uses AAC for Apple devices and SBC for
# others. These bitpool settings affect SBC encoding quality.
#
# Understanding Bitpool:
# - Bitpool is a parameter in SBC that controls audio quality vs stability
# - Range: 2 (worst) to 64 (best possible with SBC)
# - Higher bitpool = more bits per audio frame = better quality
# - Higher bitpool = more bandwidth = potential for audio dropouts
#
# Source:       https://www.bluetooth.com/specifications/specs/advanced-audio-distribution-profile-1-4/
# See also:     man BluetoothAudioAgent

# --- Bluetooth Audio Quality (Minimum) ---
# Key:          Apple Bitpool Min (editable)
# Domain:       com.apple.BluetoothAudioAgent
# Description:  Sets the floor for SBC audio quality. macOS negotiates bitpool
#               with the connected device, starting from the initial value and
#               adjusting between min and max based on connection quality.
#
#               If audio is cutting out, the system reduces bitpool toward min.
#               Setting min too high prevents adaptation to poor conditions.
#
# Default:      2 (allows full adaptation range)
# Options:      2 (most adaptive) to 64 (locks to high quality)
# Set to:       40 (good balance - maintains quality, allows some adaptation)
# UI Location:  Not available in UI (terminal only)
# Note:         If you experience audio dropouts, lower this value.
#               40 provides noticeably better quality than default 2.
run_defaults "com.apple.BluetoothAudioAgent" "Apple Bitpool Min (editable)" "-int" "40"

# --- Bluetooth Audio Quality (Maximum) ---
# Key:          Apple Bitpool Max (editable)
# Domain:       com.apple.BluetoothAudioAgent
# Description:  Sets the ceiling for SBC audio quality. The actual bitpool used
#               will be between min and max, depending on signal quality and
#               device capabilities. Most devices support up to 53 reliably.
#
#               Why not 64 (maximum)?
#               - 64 is often unstable with many devices
#               - 53 is the "middle quality" sweet spot for SBC
#               - Some devices have firmware bugs above 53
#
# Default:      64 (maximum possible)
# Options:      2 (lowest) to 64 (highest SBC quality)
# Set to:       53 (reliable high quality without dropouts)
# UI Location:  Not available in UI (terminal only)
# Note:         If audio sounds fine, you can try increasing to 58-64.
#               Reduce if you experience crackling or dropouts.
run_defaults "com.apple.BluetoothAudioAgent" "Apple Bitpool Max (editable)" "-int" "53"

# --- Bluetooth Audio Initial Bitpool ---
# Key:          Apple Initial Bitpool (editable)
# Domain:       com.apple.BluetoothAudioAgent
# Description:  Sets the starting bitpool value when establishing a new
#               Bluetooth audio connection. The system negotiates from this
#               starting point. A higher initial value means better quality
#               from the first audio frame.
#
# Default:      35 (middle ground)
# Options:      2 to 64 (should be between min and max settings)
# Set to:       40 (start with good quality, match min setting)
# UI Location:  Not available in UI (terminal only)
# Note:         Starting at 40 avoids the "initial low quality" period that
#               can occur when starting from the default 35 and negotiating up.
run_defaults "com.apple.BluetoothAudioAgent" "Apple Initial Bitpool (editable)" "-int" "40"

# --- Negotiated Bitpool (Read Only) ---
# Key:          Apple Bitpool (editable)
# Domain:       com.apple.BluetoothAudioAgent
# Description:  This is the CURRENT negotiated bitpool value for an active
#               connection. It's determined by the min/max/initial values above
#               and the connected device's capabilities. This is informational.
#
# Check current negotiated value:
#   defaults read com.apple.BluetoothAudioAgent "Apple Bitpool (editable)"
#
# If this value is consistently low despite high min setting, your device
# may have limited Bluetooth bandwidth or interference issues.

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
