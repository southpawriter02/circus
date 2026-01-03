#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Pointer & Cursor Accessibility Settings
#
# DESCRIPTION:
#   Configures mouse and trackpad pointer accessibility options including
#   cursor size, shake to locate, and pointer control settings.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Change Pointer preferences for accessibility
#     https://support.apple.com/guide/mac-help/change-pointer-preferences-accessibility-mchlc897c394/mac
#   - Apple Support: Mouse & Trackpad accessibility
#     https://support.apple.com/guide/mac-help/mouse-trackpad-accessibility-mh43348/mac
#
# DOMAIN:
#   com.apple.universalaccess
#   com.apple.AppleMultitouchTrackpad
#   com.apple.driver.AppleBluetoothMultitouch.trackpad
#   NSGlobalDomain
#
# NOTES:
#   - Settings apply to both mouse and trackpad cursors
#   - Some settings may vary between devices
#
# ==============================================================================

msg_info "Configuring pointer accessibility settings..."

# ==============================================================================
# Cursor Size & Appearance
# ==============================================================================

# --- Cursor Size ---
# Key:          mouseDriverCursorSize
# Domain:       com.apple.universalaccess
# Description:  Size multiplier for the mouse cursor.
#               1.0 is normal size, up to 4.0 for maximum.
# Default:      1.0
# Options:      1.0 to 4.0 (float)
# Set to:       1.0 (normal size)
# UI Location:  System Settings > Accessibility > Pointer Control > Pointer size
run_defaults "com.apple.universalaccess" "mouseDriverCursorSize" "-float" "1.0"

# --- Shake Mouse Pointer to Locate ---
# Key:          shakeToLocate
# Domain:       CGDisableCursorLocationMagnification
# Description:  Enlarges the cursor when you shake the mouse rapidly,
#               making it easier to find on large displays.
# Default:      true (enabled)
# Options:      0 = Disable shake to locate
#               1 = Enable shake to locate
# Set to:       1 (enable for easy location)
# UI Location:  System Settings > Accessibility > Pointer Control > Shake mouse pointer to locate
# Note:         This key disables the feature when set to 1
run_defaults "NSGlobalDomain" "CGDisableCursorLocationMagnification" "-bool" "false"

# --- Cursor Color (macOS Monterey+) ---
# Key:          cursorColor
# Domain:       com.apple.universalaccess
# Description:  Change the cursor outline and fill colors.
# Default:      Black outline, white fill
# Note:         These settings are complex data types and best set via UI
# UI Location:  System Settings > Accessibility > Pointer Control > Pointer color

# ==============================================================================
# Pointer Speed & Acceleration
# ==============================================================================

# --- Mouse Tracking Speed ---
# Key:          com.apple.mouse.scaling
# Domain:       NSGlobalDomain
# Description:  Mouse movement speed. Higher = faster cursor movement.
# Default:      3 (medium)
# Options:      0.0 to 3.0 (float)
#               -1 = Disable mouse acceleration
# Set to:       3 (comfortable speed)
# UI Location:  System Settings > Mouse > Tracking speed
run_defaults "NSGlobalDomain" "com.apple.mouse.scaling" "-float" "3"

# --- Trackpad Tracking Speed ---
# Key:          com.apple.trackpad.scaling
# Domain:       NSGlobalDomain
# Description:  Trackpad cursor speed. Higher = faster cursor movement.
# Default:      3 (medium)
# Options:      0.0 to 3.0 (float)
# Set to:       3 (comfortable speed)
# UI Location:  System Settings > Trackpad > Tracking speed
run_defaults "NSGlobalDomain" "com.apple.trackpad.scaling" "-float" "3"

# --- Disable Mouse Acceleration ---
# Key:          com.apple.mouse.scaling
# Domain:       NSGlobalDomain
# Description:  Set to -1 to disable mouse acceleration for precise control.
#               Useful for gaming and design work.
# Note:         Uncomment the following to disable acceleration:
# run_defaults "NSGlobalDomain" "com.apple.mouse.scaling" "-float" "-1"

# ==============================================================================
# Double-Click Speed
# ==============================================================================

# --- Double-Click Speed ---
# Key:          com.apple.mouse.doubleClickThreshold
# Domain:       NSGlobalDomain
# Description:  Time interval for double-click recognition (in seconds).
#               Lower = faster double-click required.
# Default:      0.5
# Options:      0.0 to 1.5 (float, seconds)
# Set to:       0.5 (moderate speed)
# UI Location:  System Settings > Accessibility > Pointer Control > Double-click speed
run_defaults "NSGlobalDomain" "com.apple.mouse.doubleClickThreshold" "-float" "0.5"

# ==============================================================================
# Spring-Loading
# ==============================================================================

# --- Spring-Loading Speed ---
# Key:          com.apple.springing.delay
# Domain:       NSGlobalDomain
# Description:  Delay before spring-loading activates when hovering over
#               folders with a dragged item.
# Default:      0.5
# Options:      0.0 to 2.0 (float, seconds)
#               Smaller = faster activation
# Set to:       0.5 (quick response)
# UI Location:  System Settings > Accessibility > Pointer Control > Spring-loading delay
run_defaults "NSGlobalDomain" "com.apple.springing.delay" "-float" "0.5"

# --- Enable Spring-Loading ---
# Key:          com.apple.springing.enabled
# Domain:       NSGlobalDomain
# Description:  Enable or disable spring-loading for folders.
# Default:      true
# Options:      true = Enable, false = Disable
# Set to:       true (useful feature)
run_defaults "NSGlobalDomain" "com.apple.springing.enabled" "-bool" "true"

# ==============================================================================
# Scrolling
# ==============================================================================

# --- Natural Scrolling ---
# Key:          com.apple.swipescrolldirection
# Domain:       NSGlobalDomain
# Description:  Natural scrolling (content moves with finger direction).
#               When disabled, scrolling is reversed (traditional).
# Default:      true (natural scrolling)
# Options:      true = Natural (iOS-like)
#               false = Traditional (opposite to touch)
# Set to:       true (natural scrolling)
# UI Location:  System Settings > Trackpad > Scroll & Zoom > Natural scrolling
run_defaults "NSGlobalDomain" "com.apple.swipescrolldirection" "-bool" "true"

# --- Scroll Speed ---
# Key:          AppleScrollSpeed
# Domain:       NSGlobalDomain
# Description:  Controls scrolling speed.
# Default:      Varies
# Options:      Float value
# Note:         Exact behavior varies by input device

# ==============================================================================
# Mouse Keys
# ==============================================================================

# --- Enable Mouse Keys ---
# Key:          mouseKeysEnabled
# Domain:       com.apple.universalaccess
# Description:  Use the keyboard numpad to move the mouse cursor.
#               Useful when mouse is unavailable.
# Default:      false
# Options:      true = Enable mouse keys
#               false = Disable mouse keys
# Set to:       false (not commonly needed)
# UI Location:  System Settings > Accessibility > Pointer Control > Alternate Control Methods > Mouse Keys
run_defaults "com.apple.universalaccess" "mouseKeysEnabled" "-bool" "false"

# ==============================================================================
# Keyboard Accessibility (Slow Keys & Sticky Keys)
# ==============================================================================

# --- Slow Keys ---
# Key:          slowKey
# Domain:       com.apple.universalaccess
# Description:  Enables Slow Keys, which adds a delay between when a key is
#               pressed and when it registers. This helps users who accidentally
#               press keys or have difficulty pressing keys briefly.
# Default:      false (disabled)
# Options:      true  = Enable slow keys
#               false = Disable slow keys (normal key response)
# Set to:       false (disabled for typical users)
# UI Location:  System Settings > Accessibility > Keyboard > Slow Keys
# Source:       https://support.apple.com/guide/mac-help/change-accessibility-keyboard-settings-mchlc898a9b2/mac
run_defaults "com.apple.universalaccess" "slowKey" "-bool" "false"

# --- Slow Keys Delay ---
# Key:          slowKeyDelay
# Domain:       com.apple.universalaccess
# Description:  Sets the delay (in seconds) a key must be held before it
#               registers when Slow Keys is enabled. Longer delays prevent
#               accidental key presses but require more deliberate key holds.
# Default:      0.25 (quarter second)
# Options:      Float value in seconds (0.0 to 2.0 typical range)
#               0.1  = Very short delay
#               0.25 = Default
#               0.5  = Half second
#               1.0  = Full second
# Set to:       0.25 (standard delay if slow keys is enabled)
# UI Location:  System Settings > Accessibility > Keyboard > Slow Keys > Delay slider
# Source:       https://support.apple.com/guide/mac-help/change-accessibility-keyboard-settings-mchlc898a9b2/mac
run_defaults "com.apple.universalaccess" "slowKeyDelay" "-float" "0.25"

# --- Sticky Keys ---
# Key:          stickyKey
# Domain:       com.apple.universalaccess
# Description:  Enables Sticky Keys, which allows modifier keys (Shift, Control,
#               Option, Command) to be pressed one at a time rather than held
#               simultaneously. Useful for users who have difficulty pressing
#               multiple keys at once.
# Default:      false (disabled)
# Options:      true  = Enable sticky keys
#               false = Disable sticky keys (normal modifier behavior)
# Set to:       false (disabled for typical users)
# UI Location:  System Settings > Accessibility > Keyboard > Sticky Keys
# Source:       https://support.apple.com/guide/mac-help/change-accessibility-keyboard-settings-mchlc898a9b2/mac
# Note:         When enabled, press a modifier key once to activate it for the
#               next key press, or press it twice to lock it.
run_defaults "com.apple.universalaccess" "stickyKey" "-bool" "false"

# --- Sticky Keys Sound ---
# Key:          stickyKeyBeep
# Domain:       com.apple.universalaccess
# Description:  Plays a sound when a modifier key is pressed, locked, or released
#               while Sticky Keys is enabled. Provides audio feedback about the
#               current state of modifier keys.
# Default:      false (no sound)
# Options:      true  = Play sound for sticky key events
#               false = Silent sticky keys operation
# Set to:       false (silent operation)
# UI Location:  System Settings > Accessibility > Keyboard > Sticky Keys > Play a sound when a modifier key is set
# Source:       https://support.apple.com/guide/mac-help/change-accessibility-keyboard-settings-mchlc898a9b2/mac
run_defaults "com.apple.universalaccess" "stickyKeyBeepOnModifier" "-bool" "false"

# ==============================================================================
# Pointer Control - Alternate Control Methods
#
# These settings are configured in:
# System Settings > Accessibility > Pointer Control > Alternate Control Methods
#
# - Mouse Keys: Use keyboard to control pointer
# - Head Pointer: Use head movements to control pointer (requires camera)
# - Alternate Pointer Actions: Alternative ways to click
#
# These are specialized accessibility features typically configured
# through the UI for users who need them.
#
# ==============================================================================

# ==============================================================================
# Trackpad Gestures
# ==============================================================================

# --- Tap to Click ---
# Key:          Clicking
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Enable tap to click on trackpad.
# Default:      false (click requires press)
# Options:      true = Tap to click, false = Press to click
# Set to:       true (tap to click for convenience)
# UI Location:  System Settings > Trackpad > Point & Click > Tap to click
run_defaults "com.apple.AppleMultitouchTrackpad" "Clicking" "-bool" "true"
run_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "Clicking" "-bool" "true"

# --- Force Click and Haptic Feedback ---
# Key:          ActuateDetents
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Enable haptic feedback for Force Touch trackpads.
# Default:      true
# Options:      true = Enable haptic feedback
#               false = Disable haptic feedback
# Set to:       true (useful tactile feedback)
# UI Location:  System Settings > Trackpad > Point & Click > Force Click and haptic feedback
run_defaults "com.apple.AppleMultitouchTrackpad" "ActuateDetents" "-bool" "true"

# --- Click Pressure (Force Touch trackpads) ---
# Key:          FirstClickThreshold
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Pressure required for click. Lower = lighter click.
# Default:      1 (medium)
# Options:      0 = Light, 1 = Medium, 2 = Firm
# Set to:       1 (medium)
# UI Location:  System Settings > Trackpad > Point & Click > Click
run_defaults "com.apple.AppleMultitouchTrackpad" "FirstClickThreshold" "-int" "1"
run_defaults "com.apple.AppleMultitouchTrackpad" "SecondClickThreshold" "-int" "1"

# --- Dragging Style ---
# Key:          Dragging
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Enable dragging with trackpad.
# Default:      false
# Options:      true = Enable, false = Disable
# Note:         Three-finger drag is in Accessibility settings
# UI Location:  System Settings > Accessibility > Pointer Control > Trackpad Options > Dragging style
run_defaults "com.apple.AppleMultitouchTrackpad" "Dragging" "-bool" "false"

# --- Three Finger Drag ---
# Key:          TrackpadThreeFingerDrag
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Enable three-finger dragging on trackpad.
# Default:      false
# Options:      true = Enable three-finger drag
#               false = Disable (use tap or click-drag)
# Set to:       false (can be awkward; enable if preferred)
# UI Location:  System Settings > Accessibility > Pointer Control > Trackpad Options > Dragging style > Three-finger drag
run_defaults "com.apple.AppleMultitouchTrackpad" "TrackpadThreeFingerDrag" "-bool" "false"
run_defaults "com.apple.driver.AppleBluetoothMultitouch.trackpad" "TrackpadThreeFingerDrag" "-bool" "false"

msg_success "Pointer accessibility settings configured."

# ==============================================================================
# Additional Notes
#
# To reset trackpad to defaults:
#   defaults delete com.apple.AppleMultitouchTrackpad
#   defaults delete com.apple.driver.AppleBluetoothMultitouch.trackpad
#
# For gaming (disable acceleration):
#   defaults write NSGlobalDomain com.apple.mouse.scaling -float -1
#
# For large displays (bigger cursor):
#   defaults write com.apple.universalaccess mouseDriverCursorSize -float 2.0
#
# ==============================================================================
