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
#               physically pressing down.
# Default:      0 (disabled - must press to click)
# Possible:     0 = Disabled (press to click)
#               1 = Enabled (tap to click)
# Set to:       1 (tap to click enabled)
# Reference:    System Preferences > Trackpad > Point & Click > Tap to click
# Note:         Both domains must be set to affect all trackpads
run_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "-int" "1"
run_defaults "com.apple.AppleMultitouchTrackpad" "Clicking" "-int" "1"

# --- Trackpad Tracking Speed ---
# Key:          com.apple.trackpad.scaling
# Domain:       NSGlobalDomain
# Description:  Controls how fast the cursor moves relative to finger
#               movement on the trackpad. Higher values mean faster cursor
#               movement for less finger travel.
# Default:      1.0
# Possible:     Float value; range approximately 0.0 to 3.0
#               0.0 = Slowest
#               1.0 = Default
#               2.0 = Fast
#               3.0 = Very fast
# Set to:       2.0 (moderately fast for efficient navigation)
# Reference:    System Preferences > Trackpad > Point & Click > Tracking speed
run_defaults "NSGlobalDomain" "com.apple.trackpad.scaling" "-float" "2.0"


# ==============================================================================
# Mouse Settings
# ==============================================================================

# --- Mouse Tracking Speed ---
# Key:          com.apple.mouse.scaling
# Domain:       NSGlobalDomain
# Description:  Controls how fast the cursor moves relative to physical
#               mouse movement. Higher values mean faster cursor movement.
# Default:      1.0
# Possible:     Float value; range approximately 0.0 to 3.0
#               0.0 = Slowest (linear, no acceleration)
#               1.0 = Default
#               2.0 = Fast
#               3.0 = Very fast
# Set to:       2.0 (moderately fast for efficient navigation)
# Reference:    System Preferences > Mouse > Tracking speed
# Note:         Some gaming mice have their own software that overrides this
run_defaults "NSGlobalDomain" "com.apple.mouse.scaling" "-float" "2.0"


# ==============================================================================
# Scrolling Behavior (Applies to both Trackpad and Mouse)
# ==============================================================================

# --- Disable "Natural" Scrolling ---
# Key:          com.apple.swipescrolldirection
# Domain:       NSGlobalDomain
# Description:  Controls the scroll direction for trackpads and mice.
#               - "Natural" scrolling: Content moves in the direction of
#                 your finger swipe (like on iOS). Scrolling up moves
#                 content up (revealing content below).
#               - Traditional scrolling: The scrollbar moves in the
#                 direction of your gesture. Scrolling up moves the
#                 scrollbar up (revealing content above).
# Default:      true (natural scrolling enabled)
# Possible:     true = Natural scrolling (iOS-like)
#               false = Traditional scrolling (classic)
# Set to:       false (traditional scrolling)
# Reference:    System Preferences > Trackpad > Scroll & Zoom > Scroll direction: Natural
# Note:         This is highly personal preference; many long-time Mac
#               users prefer traditional scrolling
run_defaults "NSGlobalDomain" "com.apple.swipescrolldirection" "-bool" "false"


msg_success "Trackpad and Mouse settings applied. A restart may be required for all changes to take effect."
