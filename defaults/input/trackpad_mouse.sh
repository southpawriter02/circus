#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Trackpad & Mouse Configuration
#
# DESCRIPTION:
#   This script configures settings for the trackpad and mouse, including
#   tap-to-click, tracking speed, and scroll direction. These settings
#   optimize input devices for efficient navigation and interaction.
#
# REQUIRES:
#   - macOS 10.7 (Lion) or later for most trackpad gestures
#   - macOS 10.5 (Leopard) or later for basic settings
#
# REFERENCES:
#   - Apple Support: Change Trackpad preferences on Mac
#     https://support.apple.com/guide/mac-help/change-trackpad-preferences-mchlp1226/mac
#   - Apple Support: Change Mouse preferences on Mac
#     https://support.apple.com/guide/mac-help/change-mouse-preferences-mchlp1138/mac
#   - Apple Support: Use Multi-Touch gestures on your Mac
#     https://support.apple.com/en-us/102482
#
# DOMAINS:
#   NSGlobalDomain                                    - System-wide settings
#   com.apple.driver.AppleBluetoothMultitouch.trackpad - Bluetooth trackpad
#   com.apple.AppleMultitouchTrackpad                  - Built-in trackpad
#
# NOTES:
#   - A restart may be required for all changes to take effect
#   - "Natural" scrolling moves content with your finger direction
#   - Trackpad settings apply to both built-in and external Magic Trackpad
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Trackpad/Mouse preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Trackpad and Mouse settings..."

# ==============================================================================
# Trackpad Settings
# ==============================================================================

# --- Enable Tap to Click ---
# Key:          Clicking
# Domains:      com.apple.driver.AppleBluetoothMultitouch.trackpad (external)
#               com.apple.AppleMultitouchTrackpad (built-in)
# Description:  Enables the "Tap to click" feature, allowing a light tap
#               on the trackpad surface to register as a click without
#               physically pressing down. This provides a quieter and
#               gentler interaction with the trackpad.
# Default:      0 (disabled - must press to click)
# Options:      0 = Disabled (physical press required to click)
#               1 = Enabled (light tap registers as click)
# Set to:       1 (tap to click enabled for faster interaction)
# UI Location:  System Settings > Trackpad > Point & Click > Tap to click
# Source:       https://support.apple.com/guide/mac-help/change-trackpad-settings-mchlp1226/mac
# See also:     https://support.apple.com/en-us/102482 (Multi-Touch gestures)
# Note:         Both domains must be set to affect all trackpads (built-in
#               and external Magic Trackpad)
run_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "-int" "1"
run_defaults "com.apple.AppleMultitouchTrackpad" "Clicking" "-int" "1"

# --- Trackpad Tracking Speed ---
# Key:          com.apple.trackpad.scaling
# Domain:       NSGlobalDomain
# Description:  Controls how fast the cursor moves relative to finger
#               movement on the trackpad. Higher values mean faster cursor
#               movement for less finger travel. This is a multiplier that
#               affects cursor acceleration.
# Default:      1.0 (medium speed, centered on slider)
# Options:      Float value; range approximately 0.0 to 3.0
#               0.0 = Slowest (minimal cursor movement)
#               1.0 = Default (balanced speed)
#               2.0 = Fast (recommended for large displays)
#               3.0 = Very fast (maximum acceleration)
# Set to:       2.0 (moderately fast for efficient navigation)
# UI Location:  System Settings > Trackpad > Point & Click > Tracking speed
# Source:       https://support.apple.com/guide/mac-help/change-your-mouse-or-trackpads-response-speed-mchlp1138/mac
run_defaults "NSGlobalDomain" "com.apple.trackpad.scaling" "-float" "2.0"


# ==============================================================================
# Mouse Settings
# ==============================================================================

# --- Mouse Tracking Speed ---
# Key:          com.apple.mouse.scaling
# Domain:       NSGlobalDomain
# Description:  Controls how fast the cursor moves relative to physical
#               mouse movement. Higher values mean faster cursor movement.
#               This setting applies pointer acceleration which makes small
#               movements precise while large movements cover more distance.
# Default:      1.0 (medium speed, centered on slider)
# Options:      Float value; range approximately 0.0 to 3.0
#               0.0 = Slowest (linear movement, no acceleration)
#               1.0 = Default (balanced acceleration)
#               2.0 = Fast (less physical movement needed)
#               3.0 = Very fast (maximum acceleration)
# Set to:       2.0 (moderately fast for efficient navigation)
# UI Location:  System Settings > Mouse > Tracking speed
# Source:       https://support.apple.com/guide/mac-help/change-your-mouse-or-trackpads-response-speed-mchlp1138/mac
# Note:         Some gaming mice have their own software that overrides this
#               setting. Third-party mice may require their vendor's drivers.
run_defaults "NSGlobalDomain" "com.apple.mouse.scaling" "-float" "2.0"


# ==============================================================================
# Scrolling Behavior (Applies to both Trackpad and Mouse)
# ==============================================================================

# --- Disable "Natural" Scrolling ---
# Key:          com.apple.swipescrolldirection
# Domain:       NSGlobalDomain
# Description:  Controls the scroll direction for trackpads and mice.
#               - "Natural" scrolling (true): Content moves in the direction
#                 of your finger swipe, like touching paper or an iOS device.
#                 Swipe up = content moves up (you see content below).
#               - Traditional scrolling (false): The viewport moves in the
#                 direction of your gesture, like dragging a scrollbar.
#                 Swipe up = viewport moves up (you see content above).
# Default:      true (natural scrolling enabled since macOS Lion 10.7)
# Options:      true  = Natural scrolling (iOS-style, content follows finger)
#               false = Traditional scrolling (classic Mac/Windows behavior)
# Set to:       false (traditional scrolling for users accustomed to classic behavior)
# UI Location:  System Settings > Trackpad > Scroll & Zoom > Natural scrolling
#               System Settings > Mouse > Natural scrolling
# Source:       https://support.apple.com/guide/mac-help/change-trackpad-settings-mchlp1226/mac
# Note:         This is highly personal preference. Users who switch between
#               Mac and Windows may prefer traditional scrolling for consistency.
#               This setting affects both trackpad and mouse scrolling globally.
run_defaults "NSGlobalDomain" "com.apple.swipescrolldirection" "-bool" "false"


msg_success "Trackpad and Mouse settings applied. A restart may be required for all changes to take effect."
