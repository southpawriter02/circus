#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Zoom Accessibility Settings
#
# DESCRIPTION:
#   Configures screen zoom accessibility options including keyboard shortcuts,
#   scroll gesture zoom, and zoom style settings.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Zoom in on the Mac screen
#     https://support.apple.com/guide/mac-help/zoom-in-on-the-mac-screen-mh35715/mac
#   - Apple Support: Zoom preferences for accessibility
#     https://support.apple.com/guide/mac-help/change-zoom-preferences-mchl70c97e7f/mac
#
# DOMAIN:
#   com.apple.universalaccess
#   com.apple.AppleMultitouchTrackpad
#
# NOTES:
#   - Zoom can use keyboard shortcuts or scroll gestures
#   - Multiple zoom styles available (full screen, split screen, picture-in-picture)
#   - Zoom works with all apps and content
#
# ==============================================================================

msg_info "Configuring zoom accessibility settings..."

# ==============================================================================
# Enable Zoom
# ==============================================================================

# --- Enable Keyboard Shortcuts for Zoom ---
# Key:          closeViewZoomFollowsFocus
# Domain:       com.apple.universalaccess
# Description:  Enable zoom keyboard shortcuts:
#               - Option + Cmd + 8: Toggle zoom
#               - Option + Cmd + =: Zoom in
#               - Option + Cmd + -: Zoom out
# Default:      false
# Options:      true = Enable keyboard zoom
#               false = Disable keyboard zoom
# Set to:       true (useful accessibility feature)
# UI Location:  System Settings > Accessibility > Zoom > Use keyboard shortcuts to zoom
run_defaults "com.apple.universalaccess" "closeViewZoomFollowsFocus" "-bool" "true"

# --- Enable Scroll Gesture with Modifier Key ---
# Key:          closeViewScrollWheelToggle
# Domain:       com.apple.universalaccess
# Description:  Enable zoom by holding a modifier key and scrolling.
# Default:      false
# Options:      true = Enable scroll gesture zoom
#               false = Disable scroll gesture zoom
# Set to:       true (quick zoom with Control + scroll)
# UI Location:  System Settings > Accessibility > Zoom > Use scroll gesture with modifier keys to zoom
run_defaults "com.apple.universalaccess" "closeViewScrollWheelToggle" "-bool" "true"

# --- Scroll Gesture Modifier Key ---
# Key:          closeViewScrollWheelModifiersInt
# Domain:       com.apple.universalaccess
# Description:  Which modifier key to hold for scroll gesture zoom.
# Default:      262144 (Control key)
# Options:      262144 = Control
#               524288 = Option
#               1048576 = Command
#               131072 = Shift
# Set to:       262144 (Control key)
# UI Location:  System Settings > Accessibility > Zoom > Use scroll gesture with modifier keys to zoom
run_defaults "com.apple.universalaccess" "closeViewScrollWheelModifiersInt" "-int" "262144"

# ==============================================================================
# Zoom Style
# ==============================================================================

# --- Zoom Style ---
# Key:          closeViewZoomMode
# Domain:       com.apple.universalaccess
# Description:  How the zoomed view is displayed.
# Default:      0 (Full screen)
# Options:      0 = Full screen (entire screen zooms)
#               1 = Split screen (zoomed area in portion of screen)
#               2 = Picture-in-picture (zoomed area in floating window)
# Set to:       0 (full screen zoom)
# UI Location:  System Settings > Accessibility > Zoom > Zoom style
run_defaults "com.apple.universalaccess" "closeViewZoomMode" "-int" "0"

# ==============================================================================
# Zoom Behavior
# ==============================================================================

# --- Smooth Images ---
# Key:          closeViewSmoothImages
# Domain:       com.apple.universalaccess
# Description:  Smooth images when zooming to reduce pixelation.
# Default:      true
# Options:      true = Smooth images (anti-aliased)
#               false = Pixelated zoom
# Set to:       true (cleaner appearance)
# UI Location:  System Settings > Accessibility > Zoom > Smooth images
run_defaults "com.apple.universalaccess" "closeViewSmoothImages" "-bool" "true"

# --- Zoom Follows Focus ---
# Key:          closeViewZoomFollowsFocus
# Domain:       com.apple.universalaccess
# Description:  Zoom window follows keyboard focus.
# Default:      true
# Options:      true = Follow keyboard focus
#               false = Manual control only
# Set to:       true (convenient for keyboard users)
# UI Location:  System Settings > Accessibility > Zoom > Follow the keyboard focus
run_defaults "com.apple.universalaccess" "closeViewZoomFollowsFocus" "-bool" "true"

# ==============================================================================
# Zoom Limits
# ==============================================================================

# --- Maximum Zoom Level ---
# Key:          closeViewFarPoint
# Domain:       com.apple.universalaccess
# Description:  Maximum zoom magnification level.
# Default:      1 (100%, no zoom)
# Options:      1 to 40 (1x to 40x zoom)
# Note:         Higher values allow more extreme zoom
# Set to:       20 (20x maximum zoom)
# UI Location:  System Settings > Accessibility > Zoom > Maximum zoom
run_defaults "com.apple.universalaccess" "closeViewFarPoint" "-int" "1"

# --- Minimum Zoom Level ---
# Key:          closeViewNearPoint
# Domain:       com.apple.universalaccess
# Description:  Minimum zoom level (used as the "zoomed" state).
# Default:      Varies
# Options:      Integer value
# Set to:       20 (20x zoom when zoomed in)
# UI Location:  System Settings > Accessibility > Zoom > Minimum zoom
run_defaults "com.apple.universalaccess" "closeViewNearPoint" "-int" "20"

# ==============================================================================
# Touch Bar Zoom (MacBooks with Touch Bar)
#
# Touch Bar zoom settings are in:
# System Settings > Accessibility > Zoom > Enable Touch Bar zoom
#
# When enabled, holding the Touch Bar shows a larger version of it on screen.
# This is primarily useful for accessibility and cannot be easily set via defaults.
#
# ==============================================================================

# ==============================================================================
# Hover Text
# ==============================================================================

# --- Enable Hover Text ---
# Key:          hoverTextEnabled
# Domain:       com.apple.universalaccess
# Description:  Show enlarged text when hovering over items while holding
#               Command key.
# Default:      false
# Options:      true = Enable hover text
#               false = Disable hover text
# Set to:       false (not commonly needed)
# UI Location:  System Settings > Accessibility > Zoom > Hover Text
# Note:         Useful for users who need occasional text magnification
run_defaults "com.apple.universalaccess" "hoverTextEnabled" "-bool" "false"

# --- Hover Text Font Size ---
# Key:          hoverTextFontSize
# Domain:       com.apple.universalaccess
# Description:  Sets the font size for the hover text magnification feature.
#               Larger values make the magnified text bigger when holding
#               Command over text elements.
# Default:      32
# Options:      Integer value (points):
#               16  = Small
#               32  = Medium (default)
#               64  = Large
#               128 = Very large
# Set to:       32 (comfortable reading size)
# UI Location:  System Settings > Accessibility > Zoom > Hover Text > Text size
# Source:       https://support.apple.com/guide/mac-help/change-zoom-preferences-mchl70c97e7f/mac
# Note:         Only applies when hoverTextEnabled is true.
run_defaults "com.apple.universalaccess" "hoverTextFontSize" "-int" "32"

# --- Flash Screen on Zoom Toggle ---
# Key:          closeViewFlashScreen
# Domain:       com.apple.universalaccess
# Description:  Briefly flashes the screen when zoom is toggled on or off,
#               providing visual confirmation that the zoom state has changed.
# Default:      false (no flash)
# Options:      true  = Flash screen when toggling zoom
#               false = No visual feedback on zoom toggle
# Set to:       false (no flash - can be distracting)
# UI Location:  System Settings > Accessibility > Zoom > Flash screen when zoom changes
# Source:       https://support.apple.com/guide/mac-help/change-zoom-preferences-mchl70c97e7f/mac
run_defaults "com.apple.universalaccess" "closeViewFlashScreen" "-bool" "false"

# ==============================================================================
# Pinch to Zoom (Trackpad)
# ==============================================================================

# --- Pinch to Zoom Gesture ---
# Key:          TrackpadPinchToZoom
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Enable pinch gesture to zoom in apps that support it.
#               This is app-level zoom, not accessibility zoom.
# Default:      true
# Options:      true = Enable pinch to zoom
#               false = Disable pinch to zoom
# Set to:       true (natural gesture for zooming)
# UI Location:  System Settings > Trackpad > Scroll & Zoom > Zoom in or out
run_defaults "com.apple.AppleMultitouchTrackpad" "TrackpadPinchToZoom" "-bool" "true"

# --- Smart Zoom (Double-tap with two fingers) ---
# Key:          TrackpadTwoFingerDoubleTapGesture
# Domain:       com.apple.AppleMultitouchTrackpad
# Description:  Double-tap with two fingers to smart zoom (zoom to fit).
# Default:      1 (enabled)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       1 (useful for quick zoom)
# UI Location:  System Settings > Trackpad > Scroll & Zoom > Smart zoom
run_defaults "com.apple.AppleMultitouchTrackpad" "TrackpadTwoFingerDoubleTapGesture" "-int" "1"

msg_success "Zoom accessibility settings configured."

# ==============================================================================
# Keyboard Shortcuts Reference
#
# When keyboard shortcuts are enabled:
# - Option + Cmd + 8: Toggle zoom on/off
# - Option + Cmd + = (or +): Zoom in
# - Option + Cmd + -: Zoom out
# - Option + Cmd + /: Toggle image smoothing
#
# When scroll gesture is enabled:
# - Hold Control (or chosen modifier) + Scroll: Zoom in/out
#
# ==============================================================================

# ==============================================================================
# Additional Notes
#
# For presentations:
#   Enable scroll gesture zoom for quick magnification of screen areas
#   during presentations or demonstrations.
#
# For development:
#   Zoom can be helpful for inspecting fine UI details.
#
# Reset zoom:
#   Option + Cmd + 8 toggles zoom off completely
#
# ==============================================================================
